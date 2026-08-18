const pool = require('../config/db');

const getDashboardStats = async (req, res) => {
  try {
    const [[{ total_clients }]] = await pool.execute("SELECT COUNT(*) AS total_clients FROM users WHERE role = 'client'");
    const [[{ active_pros }]] = await pool.execute("SELECT COUNT(*) AS active_pros FROM users WHERE role = 'professional' AND status = 'active'");
    const [[{ pending_pros }]] = await pool.execute("SELECT COUNT(*) AS pending_pros FROM users WHERE role = 'professional' AND status = 'pending'");
    const [[{ active_requests }]] = await pool.execute("SELECT COUNT(*) AS active_requests FROM service_requests WHERE status IN ('pending', 'assigned', 'on_the_way', 'arrived', 'in_progress')");
    const [[{ completed_requests }]] = await pool.execute("SELECT COUNT(*) AS completed_requests FROM service_requests WHERE status = 'completed'");
    const [[{ total_revenue }]] = await pool.execute("SELECT COALESCE(SUM(amount), 0) AS total_revenue FROM payments WHERE status = 'paid'");

    res.json({
      status: 'success',
      stats: {
        total_clients,
        active_pros,
        pending_pros,
        active_requests,
        completed_requests,
        total_revenue: parseFloat(total_revenue)
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar métricas do dashboard.' });
  }
};

const getPendingPros = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT id, name, cpf, email, phone, address, status, document_id, document_photo, profile_photo, residence_proof, operation_area, resume, certifications, created_at
       FROM users
       WHERE role = 'professional' AND status = 'pending'
       ORDER BY created_at ASC`
    );
    res.json({ status: 'success', professionals: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar profissionais pendentes.' });
  }
};

const updateUserStatus = async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.body; // 'active', 'pending', 'blocked'

    if (!['active', 'pending', 'blocked'].includes(status)) {
      return res.status(400).json({ status: 'error', message: 'Status de usuário inválido.' });
    }

    const [result] = await pool.execute('UPDATE users SET status = ? WHERE id = ?', [status, userId]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Usuário não encontrado.' });
    }

    res.json({ status: 'success', message: `Status do usuário atualizado para '${status}'.` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao atualizar usuário.' });
  }
};

const createCategory = async (req, res) => {
  try {
    const { name, description } = req.body;
    if (!name) {
      return res.status(400).json({ status: 'error', message: 'Nome da categoria é obrigatório.' });
    }

    const [result] = await pool.execute(
      'INSERT INTO service_categories (name, description, active) VALUES (?, ?, 1)',
      [name, description || '']
    );

    res.status(201).json({ status: 'success', categoryId: result.insertId, message: 'Categoria criada com sucesso.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao criar categoria.' });
  }
};

const listPromotions = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM promotions ORDER BY created_at DESC');
    res.json({ status: 'success', promotions: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao listar promoções.' });
  }
};

const createPromotion = async (req, res) => {
  try {
    const { code, title, discount_percent, valid_until } = req.body;
    if (!code || !title || !discount_percent) {
      return res.status(400).json({ status: 'error', message: 'Dados de promoção incompletos.' });
    }

    const [result] = await pool.execute(
      'INSERT INTO promotions (code, title, discount_percent, valid_until, active) VALUES (?, ?, ?, ?, 1)',
      [code, title, discount_percent, valid_until || null]
    );

    res.status(201).json({ status: 'success', promotionId: result.insertId, message: 'Promoção criada com sucesso.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao criar promoção.' });
  }
};

module.exports = {
  getDashboardStats,
  getPendingPros,
  updateUserStatus,
  createCategory,
  listPromotions,
  createPromotion
};
