from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql
import os

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'app_odontoped_user'),
    'password': os.getenv('DB_PASSWORD', 'DevClinica2026!'),
    'database': 'clinica_odontologica',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

def get_connection():
    return pymysql.connect(**DB_CONFIG)

# ─── AGENDA COMPLETA (via View) ───────────────────────────────────────────────
@app.route('/api/agenda', methods=['GET'])
def get_agenda():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM vw_agenda_completa ORDER BY data_hora DESC")
            rows = cur.fetchall()
        conn.close()
        for r in rows:
            if r.get('data_hora'):
                r['data_hora'] = str(r['data_hora'])
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── FATURAMENTO POR DENTISTA (via View) ─────────────────────────────────────
@app.route('/api/faturamento', methods=['GET'])
def get_faturamento():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM vw_faturamento_dentistas")
            rows = cur.fetchall()
        conn.close()
        for r in rows:
            if r.get('receita_gerada'):
                r['receita_gerada'] = float(r['receita_gerada'])
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── PACIENTES ────────────────────────────────────────────────────────────────
@app.route('/api/pacientes', methods=['GET'])
def get_pacientes():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT u.id_usuario, u.nome, u.log_in, c.endereco, c.historico_hospitalar
                FROM usuarios u
                JOIN cliente c ON u.id_usuario = c.id_cliente
            """)
            rows = cur.fetchall()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── DENTISTAS ────────────────────────────────────────────────────────────────
@app.route('/api/dentistas', methods=['GET'])
def get_dentistas():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT u.id_usuario, u.nome, d.cro, d.especializacao
                FROM usuarios u
                JOIN dentista d ON u.id_usuario = d.id_dentista
            """)
            rows = cur.fetchall()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── ESTOQUE (alerta de vencimento) ──────────────────────────────────────────
@app.route('/api/estoque', methods=['GET'])
def get_estoque():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, tipo_equipamento, quantidade, finalidade, validade,
                       CASE WHEN validade < CURDATE() THEN 'vencido'
                            WHEN validade < DATE_ADD(CURDATE(), INTERVAL 60 DAY) THEN 'alerta'
                            ELSE 'ok' END AS status_validade
                FROM estoque ORDER BY validade ASC
            """)
            rows = cur.fetchall()
        conn.close()
        for r in rows:
            if r.get('validade'):
                r['validade'] = str(r['validade'])
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── FINANCEIRO ───────────────────────────────────────────────────────────────
@app.route('/api/financeiro', methods=['GET'])
def get_financeiro():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id_financeiro, tipo, valor, data_pgto, data_vencimento,
                       forma_pgto, status_pgto, descricao, id_consulta
                FROM financeiro ORDER BY data_vencimento DESC
            """)
            rows = cur.fetchall()
        conn.close()
        for r in rows:
            for k in ['data_pgto', 'data_vencimento']:
                if r.get(k): r[k] = str(r[k])
            if r.get('valor'): r['valor'] = float(r['valor'])
        return jsonify(rows)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── AGENDAR CONSULTA (via Procedure) ────────────────────────────────────────
@app.route('/api/consultas', methods=['POST'])
def agendar_consulta():
    data = request.json
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.callproc('sp_agendar_consulta', [
                data['data_hora'], data['tipo'], data['id_paciente'],
                data['id_dentista'], data.get('status', 'Agendada')
            ])
        conn.commit()
        conn.close()
        return jsonify({'message': 'Consulta agendada com sucesso!'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ─── DASHBOARD STATS ─────────────────────────────────────────────────────────
@app.route('/api/stats', methods=['GET'])
def get_stats():
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) as total FROM consulta WHERE status_consulta != 'Cancelada'")
            consultas = cur.fetchone()['total']
            cur.execute("SELECT COUNT(*) as total FROM cliente")
            pacientes = cur.fetchone()['total']
            cur.execute("SELECT COALESCE(SUM(valor),0) as total FROM financeiro WHERE tipo='Receita' AND status_pgto='Pago'")
            receita = float(cur.fetchone()['total'])
            cur.execute("SELECT COUNT(*) as total FROM estoque WHERE validade < DATE_ADD(CURDATE(), INTERVAL 60 DAY)")
            estoque_critico = cur.fetchone()['total']
        conn.close()
        return jsonify({
            'consultas_ativas': consultas,
            'total_pacientes': pacientes,
            'receita_total': receita,
            'estoque_critico': estoque_critico
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
