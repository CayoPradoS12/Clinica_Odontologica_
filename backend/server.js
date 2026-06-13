const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const dbConfig = {
  host: 'localhost',
  user: 'readonly_dashboard',
  password: 'DashView2026!',
  database: 'clinica_odontologica',
};

async function getConnection() {
  return await mysql.createConnection(dbConfig);
}

// GET /api/agenda — exibe a view vw_agenda_completa
app.get('/api/agenda', async (req, res) => {
  let conn;
  try {
    conn = await getConnection();
    const [rows] = await conn.execute('SELECT * FROM vw_agenda_completa ORDER BY data_hora DESC');
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
});

// GET /api/faturamento — exibe a view vw_faturamento_dentistas
app.get('/api/faturamento', async (req, res) => {
  let conn;
  try {
    conn = await getConnection();
    const [rows] = await conn.execute('SELECT * FROM vw_faturamento_dentistas');
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
});

// GET /api/estoque-vencido — estoque com validade expirada
app.get('/api/estoque-vencido', async (req, res) => {
  let conn;
  try {
    conn = await getConnection();
    const [rows] = await conn.execute(
      "SELECT tipo_equipamento, quantidade, validade FROM estoque WHERE validade < CURDATE() ORDER BY validade ASC"
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});
