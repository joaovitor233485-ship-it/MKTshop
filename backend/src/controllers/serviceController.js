const pool = require('../config/db');

const listCategories = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, name, description, active FROM service_categories WHERE active = 1 ORDER BY id');
    res.json({ status: 'success', categories: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar categorias.' });
  }
};

const createRequest = async (req, res) => {
  try {
    const { user_id, category_id, problem, description, photos, address, scheduled_at, estimated_price, payment_method } = req.body;
    if (!user_id || !category_id || !problem || !description || !address) {
      return res.status(400).json({ status: 'error', message: 'Dados obrigatórios ausentes.' });
    }

    const price = estimated_price || 150.00;
    const scheduledDate = scheduled_at && /^\d{4}-\d{2}-\d{2}/.test(scheduled_at) ? scheduled_at : null;
    const method = payment_method || 'cash';
    
    // Regra: PIX ou Cartão Online requerem confirmação do pagamento pelo Admin antes de ir para os profissionais
    const initialStatus = (method === 'pix' || method === 'card_online') ? 'awaiting_payment_confirmation' : 'pending';

    const [result] = await pool.execute(
      `INSERT INTO service_requests 
        (user_id, category_id, problem, description, photos, address, scheduled_at, status, payment_method, price) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [user_id, category_id, problem, description, JSON.stringify(photos || []), address, scheduledDate, initialStatus, method, price]
    );

    res.status(201).json({
      status: 'success',
      message: initialStatus === 'awaiting_payment_confirmation' 
        ? 'Solicitação gerada! Aguardando confirmação do pagamento via Mercado Pago pelo Administrador.' 
        : 'Solicitação de serviço enviada com sucesso aos profissionais!',
      requestId: result.insertId,
      requestStatus: initialStatus,
      payment_method: method,
      estimated_price: price
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao criar solicitação.' });
  }
};

const listRequests = async (req, res) => {
  try {
    const { userId, proId, status, availableOnly } = req.query;
    let query = `
      SELECT r.id, r.user_id, r.category_id, r.professional_id, r.problem, r.description, 
             r.photos, r.address, r.scheduled_at, r.status, r.payment_method, r.price, r.completion_photos, r.completion_notes, r.created_at,
             u.name AS client_name, u.phone AS client_phone,
             c.name AS category_name,
             p.name AS pro_name, p.phone AS pro_phone
      FROM service_requests r
      JOIN users u ON u.id = r.user_id
      JOIN service_categories c ON c.id = r.category_id
      LEFT JOIN users p ON p.id = r.professional_id
      WHERE 1=1
    `;
    const params = [];

    if (userId) {
      query += ' AND r.user_id = ?';
      params.push(userId);
    }
    if (proId) {
      query += ' AND r.professional_id = ?';
      params.push(proId);
    }
    if (status) {
      query += ' AND r.status = ?';
      params.push(status);
    }
    if (availableOnly === 'true') {
      query += " AND r.status = 'pending' AND r.professional_id IS NULL";
    }

    query += ' ORDER BY r.created_at DESC';

    const [rows] = await pool.execute(query, params);

    // Formatar JSON de fotos
    const formatted = rows.map(r => ({
      ...r,
      photos: typeof r.photos === 'string' ? JSON.parse(r.photos || '[]') : r.photos || [],
      completion_photos: typeof r.completion_photos === 'string' ? JSON.parse(r.completion_photos || '[]') : r.completion_photos || []
    }));

    res.json({ status: 'success', requests: formatted });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar solicitações.' });
  }
};

const getRequestById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      `SELECT r.id, r.user_id, r.category_id, r.professional_id, r.problem, r.description, 
             r.photos, r.address, r.scheduled_at, r.status, r.payment_method, r.price, r.completion_photos, r.completion_notes, r.created_at,
             u.name AS client_name, u.phone AS client_phone, u.email AS client_email,
             c.name AS category_name,
             p.name AS pro_name, p.phone AS pro_phone, p.email AS pro_email
      FROM service_requests r
      JOIN users u ON u.id = r.user_id
      JOIN service_categories c ON c.id = r.category_id
      LEFT JOIN users p ON p.id = r.professional_id
      WHERE r.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Solicitação não encontrada.' });
    }

    const requestData = rows[0];
    requestData.photos = typeof requestData.photos === 'string' ? JSON.parse(requestData.photos || '[]') : requestData.photos || [];
    requestData.completion_photos = typeof requestData.completion_photos === 'string' ? JSON.parse(requestData.completion_photos || '[]') : requestData.completion_photos || [];

    res.json({ status: 'success', request: requestData });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar detalhes da solicitação.' });
  }
};

const acceptRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { professional_id } = req.body;

    if (!professional_id) {
      return res.status(400).json({ status: 'error', message: 'ID do profissional é obrigatório.' });
    }

    const [result] = await pool.execute(
      "UPDATE service_requests SET professional_id = ?, status = 'assigned' WHERE id = ? AND status IN ('pending', 'awaiting_payment_confirmation')",
      [professional_id, requestId]
    );

    if (result.affectedRows === 0) {
      return res.status(400).json({ status: 'error', message: 'Solicitação indisponível ou já atribuída.' });
    }

    res.json({ status: 'success', message: 'Solicitação aceita com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao aceitar solicitação.' });
  }
};

const updateStatus = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status, completion_photos, completion_notes } = req.body;

    const validStatuses = ['awaiting_payment_confirmation', 'pending', 'assigned', 'on_the_way', 'arrived', 'in_progress', 'completed', 'canceled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ status: 'error', message: 'Status inválido.' });
    }

    // Regra de Negócio: Ao finalizar o serviço (completed), a foto de comprovação do aparelho/serviço é obrigatória
    if (status === 'completed') {
      const photosArray = Array.isArray(completion_photos) ? completion_photos : (completion_photos ? [completion_photos] : []);
      if (photosArray.length === 0) {
        return res.status(400).json({
          status: 'error',
          message: 'É obrigatório enviar ao menos 1 foto do aparelho/serviço concluído como prova de execução sem defeito.'
        });
      }
    }

    const photosJson = completion_photos ? JSON.stringify(Array.isArray(completion_photos) ? completion_photos : [completion_photos]) : null;
    const notesText = completion_notes || null;

    const [result] = await pool.execute(
      'UPDATE service_requests SET status = ?, completion_photos = ?, completion_notes = ? WHERE id = ?',
      [status, photosJson, notesText, requestId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Solicitação não encontrada.' });
    }

    res.json({ status: 'success', message: `Status atualizado para '${status}'.` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao atualizar status.' });
  }
};

module.exports = {
  listCategories,
  createRequest,
  listRequests,
  getRequestById,
  acceptRequest,
  updateStatus
};

