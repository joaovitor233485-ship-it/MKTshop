const pool = require('../config/db');

const getChatHistory = async (req, res) => {
  try {
    const { requestId } = req.params;
    const [rows] = await pool.execute(
      `SELECT c.id, c.request_id, c.sender_id, c.message, c.attachments, c.created_at,
              u.name AS sender_name, u.role AS sender_role
       FROM chats c
       JOIN users u ON u.id = c.sender_id
       WHERE c.request_id = ?
       ORDER BY c.created_at ASC`,
      [requestId]
    );

    const formatted = rows.map(msg => ({
      ...msg,
      attachments: typeof msg.attachments === 'string' ? JSON.parse(msg.attachments || '[]') : msg.attachments || []
    }));

    res.json({ status: 'success', messages: formatted });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar histórico de mensagens.' });
  }
};

const sendMessage = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { sender_id, message, attachments } = req.body;

    if (!sender_id || (!message && (!attachments || attachments.length === 0))) {
      return res.status(400).json({ status: 'error', message: 'Mensagem ou anexo é obrigatório.' });
    }

    const [result] = await pool.execute(
      'INSERT INTO chats (request_id, sender_id, message, attachments) VALUES (?, ?, ?, ?)',
      [requestId, sender_id, message || '', JSON.stringify(attachments || [])]
    );

    res.status(201).json({
      status: 'success',
      messageId: result.insertId,
      message: 'Mensagem enviada com sucesso.'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao enviar mensagem.' });
  }
};

module.exports = {
  getChatHistory,
  sendMessage
};
