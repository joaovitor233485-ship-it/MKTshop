const pool = require('../config/db');

const processPayment = async (req, res) => {
  try {
    const { request_id, method, amount } = req.body;
    if (!request_id || !method || !amount) {
      return res.status(400).json({ status: 'error', message: 'Dados de pagamento incompletos.' });
    }

    const receiptCode = 'REC-' + Date.now() + '-' + Math.floor(Math.random() * 1000);

    const [result] = await pool.execute(
      'INSERT INTO payments (request_id, method, amount, status, receipt_code) VALUES (?, ?, ?, ?, ?)',
      [request_id, method, amount, 'paid', receiptCode]
    );

    // Atualiza o status do serviço para concluído se ainda não estivesse
    await pool.execute("UPDATE service_requests SET status = 'completed' WHERE id = ?", [request_id]);

    res.status(201).json({
      status: 'success',
      paymentId: result.insertId,
      receipt_code: receiptCode,
      date: new Date().toISOString(),
      message: 'Pagamento processado com sucesso! Comprovante emitido.'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao processar pagamento.' });
  }
};

const getReceipt = async (req, res) => {
  try {
    const { requestId } = req.params;
    const [rows] = await pool.execute(
      `SELECT p.id, p.request_id, p.method, p.amount, p.status, p.receipt_code, p.created_at,
              r.problem, r.address, u.name AS client_name, pro.name AS pro_name
       FROM payments p
       JOIN service_requests r ON r.id = p.request_id
       JOIN users u ON u.id = r.user_id
       LEFT JOIN users pro ON pro.id = r.professional_id
       WHERE p.request_id = ?
       ORDER BY p.created_at DESC`,
      [requestId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Comprovante de pagamento não encontrado.' });
    }

    res.json({ status: 'success', receipt: rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao consultar comprovante.' });
  }
};

module.exports = {
  processPayment,
  getReceipt
};
