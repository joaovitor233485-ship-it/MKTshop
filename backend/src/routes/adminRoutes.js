const express = require('express');
const { 
  getDashboardStats, 
  getPendingPros, 
  updateUserStatus, 
  createCategory, 
  listPromotions, 
  createPromotion,
  confirmPaymentAndRelease
} = require('../controllers/adminController');

const router = express.Router();

router.get('/stats', getDashboardStats);
router.get('/professionals/pending', getPendingPros);
router.put('/users/:userId/status', updateUserStatus);
router.post('/categories', createCategory);
router.get('/promotions', listPromotions);
router.post('/promotions', createPromotion);
router.post('/requests/:requestId/confirm-payment', confirmPaymentAndRelease);

module.exports = router;
