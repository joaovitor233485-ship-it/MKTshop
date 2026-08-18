const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const registerUser = async (req, res) => {
  try {
    const { name, cpf, email, phone, password, address, role } = req.body;
    if (!name || !cpf || !email || !phone || !password || !role) {
      return res.status(400).json({ status: 'error', message: 'Campos obrigatórios ausentes.' });
    }

    const [existing] = await pool.execute('SELECT id FROM users WHERE email = ? OR cpf = ?', [email, cpf]);
    if (existing.length > 0) {
      return res.status(409).json({ status: 'error', message: 'Usuário já existe.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      'INSERT INTO users (name, cpf, email, phone, password, address, role, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [name, cpf, email, phone, hashedPassword, address || '', role, role === 'professional' ? 'pending' : 'active']
    );

    res.status(201).json({
      status: 'success',
      user: {
        id: result.insertId,
        name,
        email,
        role,
        status: role === 'professional' ? 'pending' : 'active'
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao registrar usuário.' });
  }
};

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ status: 'error', message: 'Email e senha são obrigatórios.' });
    }

    const [rows] = await pool.execute('SELECT id, name, email, password, role, status FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(401).json({ status: 'error', message: 'Credenciais inválidas.' });
    }

    const user = rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ status: 'error', message: 'Credenciais inválidas.' });
    }

    if (user.role === 'professional' && user.status !== 'active') {
      return res.status(403).json({ status: 'error', message: 'Profissional aguardando aprovação.' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'supersecretkey',
      { expiresIn: '8h' }
    );

    res.json({
      status: 'success',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status
      },
      token
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao efetuar login.' });
  }
};

module.exports = {
  registerUser,
  loginUser
};
