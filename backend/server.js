require('dotenv').config();

console.log('🚀 Iniciando servidor...');
console.log('📊 MongoDB URI:', process.env.MONGODB_URI || 'mongodb://localhost:27017/clinica_odontologica');

const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
app.use(cors());
app.use(express.json());

// MySQL — usuário readonly para leitura das views
const dbConfig = {
  host: process.env.MYSQL_HOST || 'localhost',
  user: process.env.MYSQL_USER || 'readonly_dashboard',
  password: process.env.MYSQL_PASSWORD || 'DashView2026!',
  database: process.env.MYSQL_DATABASE || 'clinica_odontologica',
};

async function getConnection() {
  return await mysql.createConnection(dbConfig);
}

// MongoDB Atlas — prontuários (dados não estruturados)
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/clinica_odontologica';
const mongoClient = new MongoClient(MONGO_URI, { 
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 5000 
});
let prontuariosCol;
let mongoAvailable = false;
const prontuariosFallback = [];

async function connectMongo() {
  try {
    console.log('🔄 Conectando ao MongoDB...');
    await mongoClient.connect();
    prontuariosCol = mongoClient.db('clinica_odontologica').collection('prontuarios');
    mongoAvailable = true;
    console.log('✅ MongoDB conectado com sucesso!');
  } catch (err) {
    mongoAvailable = false;
    console.warn('⚠️  MongoDB não disponível. APIs de prontuário usando fallback local.');
    console.warn('   Erro:', err.message);
  }
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
  if (!mongoAvailable) {
    return res.json({ success: true, data: prontuariosFallback });
  }
  try {
    const docs = await prontuariosCol.find({}).sort({ data_registro: -1 }).toArray();
    res.json({ success: true, data: docs });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/prontuarios — cria novo prontuário
app.post('/api/prontuarios', async (req, res) => {
  const { id_paciente, nome_paciente, anotacao, dentista } = req.body;
  const doc = {
    id_paciente,
    nome_paciente,
    anotacao,
    dentista,
    data_registro: new Date(),
  };

  if (!mongoAvailable) {
    prontuariosFallback.unshift(doc);
    return res.json({ success: true, id: null, fallback: true });
  }

  try {
    const result = await prontuariosCol.insertOne(doc);
    res.json({ success: true, id: result.insertedId });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
connectMongo().finally(() => {
  app.listen(PORT, () => {
    console.log(`\n✨ API rodando em http://localhost:${PORT}\n`);
  });
});