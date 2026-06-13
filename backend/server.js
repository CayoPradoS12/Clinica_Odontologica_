const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
app.use(cors());
app.use(express.json());

// MySQL — usuário readonly para leitura das views
const dbConfig = {
  host: 'localhost',
  user: 'readonly_dashboard',
  password: 'DashView2026!',
  database: 'clinica_odontologica',
};

async function getConnection() {
  return await mysql.createConnection(dbConfig);
}

// MongoDB Atlas — prontuários (dados não estruturados)
const MONGO_URI = 'mongodb+srv://cayosantoscloud_db_user:ONg8UZq7yd0IBEOk@cluster0.bl1pkm3.mongodb.net/?appName=Cluster0';
const mongoClient = new MongoClient(MONGO_URI);
let prontuariosCol;

async function connectMongo() {
  await mongoClient.connect();
  prontuariosCol = mongoClient.db('clinica_odontologica').collection('prontuarios');
  console.log('MongoDB Atlas conectado.');
}

// ── MYSQL ROUTES ──────────────────────────────────────────

// GET /api/agenda — view vw_agenda_completa
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

// GET /api/faturamento — view vw_faturamento_dentistas
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

// GET /api/estoque-vencido — view vw_estoque_vencido
app.get('/api/estoque-vencido', async (req, res) => {
  let conn;
  try {
    conn = await getConnection();
    const [rows] = await conn.execute('SELECT * FROM vw_estoque_vencido ORDER BY validade ASC');
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
});

// ── MONGODB ROUTES ────────────────────────────────────────

// GET /api/prontuarios — lista todos os prontuários
app.get('/api/prontuarios', async (req, res) => {
  try {
    const docs = await prontuariosCol.find({}).sort({ data_registro: -1 }).toArray();
    res.json({ success: true, data: docs });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/prontuarios — cria novo prontuário
app.post('/api/prontuarios', async (req, res) => {
  try {
    const { id_paciente, nome_paciente, anotacao, dentista } = req.body;
    const doc = {
      id_paciente,
      nome_paciente,
      anotacao,
      dentista,
      data_registro: new Date(),
    };
    const result = await prontuariosCol.insertOne(doc);
    res.json({ success: true, id: result.insertedId });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = 3000;
connectMongo().then(() => {
  app.listen(PORT, () => {
    console.log(`API rodando em http://localhost:${PORT}`);
  });
}).catch(err => {
  console.error('Erro ao conectar MongoDB:', err.message);
  process.exit(1);
});