const pool = require('../config/db');

const submitReview = async (req, res) => {
  try {
    const { request_id, user_id, professional_id, rating_quality, rating_punctuality, rating_politeness, rating_organization, rating_speed, comment } = req.body;

    if (!request_id || !user_id || !professional_id) {
      return res.status(400).json({ status: 'error', message: 'Dados obrigatórios ausentes.' });
    }

    const [result] = await pool.execute(
      `INSERT INTO reviews 
        (request_id, user_id, professional_id, rating_quality, rating_punctuality, rating_politeness, rating_organization, rating_speed, comment)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        request_id, user_id, professional_id,
        rating_quality || 5, rating_punctuality || 5, rating_politeness || 5,
        rating_organization || 5, rating_speed || 5, comment || ''
      ]
    );

    res.status(201).json({
      status: 'success',
      reviewId: result.insertId,
      message: 'Avaliação enviada com sucesso! Obrigado pelo feedback.'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao enviar avaliação.' });
  }
};

const getProReviews = async (req, res) => {
  try {
    const { professionalId } = req.params;
    const [rows] = await pool.execute(
      `SELECT r.id, r.rating_quality, r.rating_punctuality, r.rating_politeness,
              r.rating_organization, r.rating_speed, r.comment, r.created_at,
              u.name AS client_name, s.problem
       FROM reviews r
       JOIN users u ON u.id = r.user_id
       JOIN service_requests s ON s.id = r.request_id
       WHERE r.professional_id = ?
       ORDER BY r.created_at DESC`,
      [professionalId]
    );

    // Calcular médias
    if (rows.length === 0) {
      return res.json({
        status: 'success',
        averageRating: 5.0,
        totalReviews: 0,
        reviews: []
      });
    }

    let sum = 0;
    rows.forEach(r => {
      const avgSingle = (r.rating_quality + r.rating_punctuality + r.rating_politeness + r.rating_organization + r.rating_speed) / 5;
      sum += avgSingle;
    });

    const averageRating = (sum / rows.length).toFixed(1);

    res.json({
      status: 'success',
      averageRating: parseFloat(averageRating),
      totalReviews: rows.length,
      reviews: rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar avaliações do profissional.' });
  }
};

module.exports = {
  submitReview,
  getProReviews
};
