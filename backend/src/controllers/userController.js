const pool = require('../config/db');

const listUsers = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, name, cpf, email, phone, address, role, status, document_id, document_photo, profile_photo, resume, certifications, operation_area, created_at FROM users'
    );
    res.json({ status: 'success', users: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar usuários.' });
  }
};

const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      'SELECT id, name, cpf, email, phone, address, role, status, document_id, document_photo, profile_photo, resume, certifications, operation_area, created_at FROM users WHERE id = ?',
      [id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Usuário não encontrado.' });
    }
    res.json({ status: 'success', user: rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar usuário.' });
  }
};

module.exports = {
  listUsers,
  getUserById
};
