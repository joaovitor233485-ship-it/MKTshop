const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const DB_FILE = path.join(__dirname, '../../database/local_db_data.json');
const defaultPasswordHash = bcrypt.hashSync('123456', 10);

const useSsl = process.env.DB_SSL === 'true' || (process.env.DB_HOST && process.env.DB_HOST !== 'localhost' && process.env.DB_HOST !== '127.0.0.1');

const mysqlPool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'shopmkt',
  ssl: useSsl ? { rejectUnauthorized: false } : undefined,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Estrutura inicial do banco em memória
const inMemoryStore = {
  users: [
    {
      id: 1,
      name: 'Cliente Exemplo',
      cpf: '111.111.111-11',
      email: 'cliente@shopmkt.com',
      phone: '(11) 99999-1111',
      password: defaultPasswordHash,
      address: 'Av. Paulista, 1000 - SP',
      role: 'client',
      status: 'active',
      created_at: new Date().toISOString()
    },
    {
      id: 2,
      name: 'Carlos Técnico',
      cpf: '222.222.222-22',
      email: 'pro@shopmkt.com',
      phone: '(11) 98888-2222',
      password: defaultPasswordHash,
      address: 'Rua Augusta, 500 - SP',
      role: 'professional',
      status: 'active',
      document_id: 'SP-12.345.678',
      operation_area: 'Assistência Técnica de Eletrônicos (Celulares & Notebooks)',
      resume: 'Técnico especialista com 8 anos de experiência em reparos de placa, troca de telas, manutenção preventiva e upgrade de hardware.',
      certifications: 'Certificação Apple ACMT • Técnico em Eletrônica Geral CREA/SP',
      created_at: new Date().toISOString()
    },
    {
      id: 3,
      name: 'Administrador',
      cpf: '333.333.333-33',
      email: 'admin@shopmkt.com',
      phone: '(11) 97777-3333',
      password: defaultPasswordHash,
      address: 'Centro - SP',
      role: 'admin',
      status: 'active',
      document_id: 'SP-99.999.999',
      operation_area: 'Gestão da Plataforma',
      resume: 'Administrador principal do sistema ShopMKT.',
      certifications: 'Gestão de Plataformas Digitais',
      created_at: new Date().toISOString()
    }
  ],
  categories: [
    { id: 1, name: 'Celular', description: 'Serviços de manutenção de celulares.', active: 1 },
    { id: 2, name: 'Notebook', description: 'Serviços de manutenção de notebooks.', active: 1 },
    { id: 3, name: 'Computador', description: 'Serviços de manutenção de computadores.', active: 1 },
    { id: 4, name: 'Videogame', description: 'Serviços para videogames e consoles.', active: 1 },
    { id: 5, name: 'Móveis', description: 'Montagem e consertos de móveis.', active: 1 },
    { id: 6, name: 'TV', description: 'Instalação e manutenção de televisores.', active: 1 },
    { id: 7, name: 'Elétrica', description: 'Serviços elétricos residenciais.', active: 1 },
    { id: 8, name: 'Hidráulica', description: 'Serviços hidráulicos residenciais.', active: 1 }
  ],
  requests: [
    {
      id: 1,
      user_id: 1,
      category_id: 1,
      professional_id: null,
      problem: 'Tela quebrada',
      description: 'Meu celular caiu da mesa. A tela ficou totalmente preta.',
      photos: JSON.stringify(['foto_tela_danificada.jpg']),
      address: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP',
      scheduled_at: null,
      status: 'pending',
      price: 150.00,
      created_at: new Date().toISOString()
    }
  ],
  chats: [],
  payments: [],
  reviews: [],
  promotions: []
};

// Funções de Persistência em Disco
const saveToDisk = () => {
  try {
    const dir = path.dirname(DB_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(DB_FILE, JSON.stringify(inMemoryStore, null, 2), 'utf8');
  } catch (e) {
    console.error('Erro ao salvar dados locais em disco:', e);
  }
};

const loadFromDisk = () => {
  try {
    if (fs.existsSync(DB_FILE)) {
      const data = fs.readFileSync(DB_FILE, 'utf8');
      const parsed = JSON.parse(data);
      if (parsed.users && parsed.requests) {
        Object.assign(inMemoryStore, parsed);
        console.log('💾 [DB Persistence] Banco de dados local carregado do disco com sucesso!');
      }
    } else {
      saveToDisk();
    }
  } catch (e) {
    console.error('Erro ao carregar dados locais do disco:', e);
  }
};

loadFromDisk();

let useInMemory = false;

const executeInMemory = async (sql, params = []) => {
  const query = sql.trim();

  // USERS QUERIES
  if (query.includes('SELECT id FROM users WHERE email = ? OR cpf = ?')) {
    const found = inMemoryStore.users.filter(u => u.email === params[0] || u.cpf === params[1]);
    return [found, []];
  }
  if (query.includes('WHERE email = ?')) {
    const found = inMemoryStore.users.filter(u => u.email === params[0]);
    return [found, []];
  }
  if (query.includes('INSERT INTO users')) {
    const newId = inMemoryStore.users.length + 1;
    const newUser = {
      id: newId,
      name: params[0],
      cpf: params[1],
      email: params[2],
      phone: params[3],
      password: params[4],
      address: params[5] || '',
      role: params[6],
      status: params[7] || 'active',
      document_id: params[8] || 'Documento em Análise',
      operation_area: params[9] || 'Manutenção Geral',
      resume: params[10] || 'Profissional autônomo cadastrado na plataforma.',
      certifications: params[11] || 'Certificações técnicas pendentes de verificação.',
      created_at: new Date().toISOString()
    };
    inMemoryStore.users.push(newUser);
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }
  if (query.includes("SELECT COUNT(*) AS total_clients FROM users WHERE role = 'client'")) {
    const count = inMemoryStore.users.filter(u => u.role === 'client').length;
    return [[{ total_clients: count }], []];
  }
  if (query.includes("SELECT COUNT(*) AS active_pros FROM users WHERE role = 'professional' AND status = 'active'")) {
    const count = inMemoryStore.users.filter(u => u.role === 'professional' && u.status === 'active').length;
    return [[{ active_pros: count }], []];
  }
  if (query.includes("SELECT COUNT(*) AS pending_pros FROM users WHERE role = 'professional' AND status = 'pending'")) {
    const count = inMemoryStore.users.filter(u => u.role === 'professional' && u.status === 'pending').length;
    return [[{ pending_pros: count }], []];
  }
  if (query.includes("WHERE role = 'professional' AND status = 'pending'")) {
    const pros = inMemoryStore.users.filter(u => u.role === 'professional' && u.status === 'pending');
    return [pros, []];
  }
  if (query.includes('UPDATE users SET status = ? WHERE id = ?')) {
    const u = inMemoryStore.users.find(user => user.id == params[1]);
    if (u) {
      u.status = params[0];
      saveToDisk();
      return [{ affectedRows: 1 }, []];
    }
    return [{ affectedRows: 0 }, []];
  }
  if (query.includes('FROM users WHERE id = ?')) {
    const found = inMemoryStore.users.filter(u => u.id == params[0]);
    return [found, []];
  }
  if (query.includes('FROM users')) {
    return [inMemoryStore.users, []];
  }

  // CATEGORIES QUERIES
  if (query.includes('SELECT id, name, description, active FROM service_categories')) {
    return [inMemoryStore.categories, []];
  }
  if (query.includes('INSERT INTO service_categories')) {
    const newId = inMemoryStore.categories.length + 1;
    inMemoryStore.categories.push({ id: newId, name: params[0], description: params[1], active: 1 });
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  // SERVICE REQUESTS QUERIES
  if (query.includes('INSERT INTO service_requests')) {
    const newId = inMemoryStore.requests.length + 1;
    const parsedPrice = typeof params[9] === 'number' ? params[9] : (parseFloat(params[9]) || 280.00);
    const newReq = {
      id: newId,
      user_id: params[0],
      category_id: params[1],
      professional_id: null,
      problem: params[2],
      description: params[3],
      photos: params[4],
      address: params[5],
      scheduled_at: params[6] || null,
      status: params[7] || 'pending',
      payment_method: params[8] || 'cash',
      price: parsedPrice,
      created_at: new Date().toISOString()
    };
    inMemoryStore.requests.push(newReq);
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  if (query.includes("UPDATE service_requests SET professional_id = ?, status = 'assigned' WHERE id = ? AND status = 'pending'")) {
    const proId = params[0];
    const reqId = params[1];
    const req = inMemoryStore.requests.find(r => r.id == reqId && r.status === 'pending');
    if (req) {
      req.professional_id = proId;
      req.status = 'assigned';
      saveToDisk();
      return [{ affectedRows: 1 }, []];
    }
    return [{ affectedRows: 0 }, []];
  }

  if (query.includes('UPDATE service_requests SET status =')) {
    const newStatus = params[0];
    const completionPhotos = params.length > 2 ? params[1] : null;
    const completionNotes = params.length > 3 ? params[2] : null;
    const reqId = params[params.length - 1];
    const req = inMemoryStore.requests.find(r => r.id == reqId);
    if (req) {
      req.status = newStatus;
      if (completionPhotos !== null) {
        req.completion_photos = completionPhotos;
      }
      if (completionNotes !== null) {
        req.completion_notes = completionNotes;
      }
      saveToDisk();
      return [{ affectedRows: 1 }, []];
    }
    return [{ affectedRows: 0 }, []];
  }

  if (query.includes("SELECT COUNT(*) AS active_requests FROM service_requests")) {
    const count = inMemoryStore.requests.filter(r => ['pending', 'assigned', 'on_the_way', 'arrived', 'in_progress'].includes(r.status)).length;
    return [[{ active_requests: count }], []];
  }
  if (query.includes("SELECT COUNT(*) AS completed_requests FROM service_requests")) {
    const count = inMemoryStore.requests.filter(r => r.status === 'completed').length;
    return [[{ completed_requests: count }], []];
  }

  if (query.includes('FROM service_requests r')) {
    let result = inMemoryStore.requests.map(r => {
      const client = inMemoryStore.users.find(u => u.id == r.user_id) || { name: 'Cliente', phone: '' };
      const category = inMemoryStore.categories.find(c => c.id == r.category_id) || { name: 'Geral' };
      const pro = inMemoryStore.users.find(u => u.id == r.professional_id) || null;
      return {
        ...r,
        client_name: client.name,
        client_phone: client.phone,
        category_name: category.name,
        pro_name: pro ? pro.name : null,
        pro_phone: pro ? pro.phone : null
      };
    });

    if (query.includes('WHERE r.id = ?')) {
      result = result.filter(r => r.id == params[0]);
    }
    if (query.includes('AND r.user_id = ?')) {
      const uIdIndex = params.length > 1 ? 0 : 0;
      result = result.filter(r => r.user_id == params[uIdIndex]);
    }
    if (query.includes('AND r.professional_id = ?')) {
      result = result.filter(r => r.professional_id == params[params.length - 1]);
    }
    if (query.includes("AND r.status = 'pending' AND r.professional_id IS NULL")) {
      result = result.filter(r => r.status === 'pending' && (!r.professional_id || r.professional_id === null));
    }
    if (query.includes('AND r.status = ?')) {
      const statusParam = params[params.length - 1];
      result = result.filter(r => r.status === statusParam);
    }

    return [result, []];
  }

  // PAYMENTS QUERIES
  if (query.includes("SELECT COALESCE(SUM(amount), 0) AS total_revenue FROM payments")) {
    const sum = inMemoryStore.payments.filter(p => p.status === 'paid').reduce((acc, p) => acc + p.amount, 0);
    return [[{ total_revenue: sum }], []];
  }
  if (query.includes('INSERT INTO payments')) {
    const newId = inMemoryStore.payments.length + 1;
    inMemoryStore.payments.push({ id: newId, request_id: params[0], method: params[1], amount: params[2], status: 'paid' });
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  // CHATS QUERIES
  if (query.includes('FROM chats')) {
    const msgs = inMemoryStore.chats
      .filter(c => c.request_id == params[0])
      .map(c => {
        const u = inMemoryStore.users.find(user => user.id == c.sender_id) || { name: 'Usuário', role: 'client' };
        return {
          ...c,
          sender_name: u.name,
          sender_role: u.role
        };
      });
    return [msgs, []];
  }
  if (query.includes('INSERT INTO chats')) {
    const newId = inMemoryStore.chats.length + 1;
    inMemoryStore.chats.push({ id: newId, request_id: params[0], sender_id: params[1], message: params[2], created_at: new Date().toISOString() });
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  // REVIEWS QUERIES
  if (query.includes('INSERT INTO reviews')) {
    const newId = inMemoryStore.reviews.length + 1;
    inMemoryStore.reviews.push({ id: newId, request_id: params[0], user_id: params[1], professional_id: params[2], rating_quality: params[3] });
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  // PROMOTIONS QUERIES
  if (query.includes('FROM promotions')) {
    return [inMemoryStore.promotions, []];
  }
  if (query.includes('INSERT INTO promotions')) {
    const newId = inMemoryStore.promotions.length + 1;
    inMemoryStore.promotions.push({ id: newId, code: params[0], title: params[1], discount_percent: params[2] });
    saveToDisk();
    return [{ insertId: newId, affectedRows: 1 }, []];
  }

  return [[], []];
};

let dbInitialized = false;
const initDb = async () => {
  if (dbInitialized) return;
  dbInitialized = true;
  try {
    const connection = await mysqlPool.getConnection();
    console.log('⚡ [DB Auto-Init] Conectado ao MySQL cloud. Verificando tabelas...');

    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        cpf VARCHAR(20) NOT NULL UNIQUE,
        email VARCHAR(150) NOT NULL UNIQUE,
        phone VARCHAR(40) NOT NULL,
        password VARCHAR(255) NOT NULL,
        address VARCHAR(255),
        role ENUM('client', 'professional', 'admin') NOT NULL DEFAULT 'client',
        status ENUM('pending', 'active', 'blocked') NOT NULL DEFAULT 'pending',
        document_id VARCHAR(100),
        document_photo VARCHAR(255),
        profile_photo VARCHAR(255),
        resume TEXT,
        certifications TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      );
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS service_categories (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description VARCHAR(255),
        active TINYINT(1) NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS service_requests (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT UNSIGNED NOT NULL,
        category_id INT UNSIGNED NOT NULL,
        professional_id INT UNSIGNED,
        problem VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        photos JSON,
        address VARCHAR(255) NOT NULL,
        scheduled_at DATETIME,
        status ENUM('pending', 'assigned', 'in_progress', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
        price DECIMAL(10,2),
        completion_photos JSON,
        completion_notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      );
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        request_id INT UNSIGNED NOT NULL,
        user_id INT UNSIGNED NOT NULL,
        professional_id INT UNSIGNED NOT NULL,
        rating_quality TINYINT UNSIGNED NOT NULL,
        rating_punctuality TINYINT UNSIGNED NOT NULL,
        rating_politeness TINYINT UNSIGNED NOT NULL,
        rating_organization TINYINT UNSIGNED NOT NULL,
        rating_speed TINYINT UNSIGNED NOT NULL,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS chats (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        request_id INT UNSIGNED NOT NULL,
        sender_id INT UNSIGNED NOT NULL,
        message TEXT,
        attachments JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    const [cats] = await connection.query('SELECT COUNT(*) as cnt FROM service_categories');
    if (cats[0].cnt === 0) {
      await connection.query(`
        INSERT INTO service_categories (id, name, description, active) VALUES
        (1, 'Celular', 'Serviços de manutenção de celulares.', 1),
        (2, 'Notebook', 'Serviços de manutenção de notebooks.', 1),
        (3, 'Computador', 'Serviços de manutenção de computadores.', 1),
        (4, 'Videogame', 'Serviços para videogames e consoles.', 1),
        (5, 'Móveis', 'Montagem e consertos de móveis.', 1),
        (6, 'TV', 'Instalação e manutenção de televisores.', 1),
        (7, 'Elétrica', 'Serviços elétricos residenciais.', 1),
        (8, 'Hidráulica', 'Serviços hidráulicos residenciais.', 1);
      `);
    }

    const [usr] = await connection.query('SELECT COUNT(*) as cnt FROM users');
    if (usr[0].cnt === 0) {
      await connection.query(`
        INSERT INTO users (id, name, cpf, email, phone, password, address, role, status) VALUES
        (1, 'Cliente Exemplo', '111.111.111-11', 'cliente@shopmkt.com', '(11) 99999-1111', '${defaultPasswordHash}', 'Av. Paulista, 1000 - SP', 'client', 'active'),
        (2, 'Carlos Técnico', '222.222.222-22', 'pro@shopmkt.com', '(11) 98888-2222', '${defaultPasswordHash}', 'Rua Augusta, 500 - SP', 'professional', 'active'),
        (3, 'Administrador', '333.333.333-33', 'admin@shopmkt.com', '(11) 97777-3333', '${defaultPasswordHash}', 'Centro - SP', 'admin', 'active');
      `);
    }

    connection.release();
    console.log('✅ [DB Auto-Init] Tabelas e dados iniciais prontos no banco cloud!');
  } catch (err) {
    console.error('⚠️ [DB Auto-Init Warning]', err.message);
  }
};

const pool = {
  execute: async (sql, params = []) => {
    if (useInMemory) {
      return executeInMemory(sql, params);
    }

    try {
      await initDb();
      return await mysqlPool.execute(sql, params);
    } catch (err) {
      if (!useInMemory) {
        console.warn(`⚠️ [DB Warning] Falha na conexão/consulta MySQL (${err.code || err.message}).`);
        console.warn('⚡ [DB Fallback] Alternando automaticamente para o banco de dados local/em memória.');
        useInMemory = true;
      }
      return executeInMemory(sql, params);
    }
  }
};

module.exports = pool;



