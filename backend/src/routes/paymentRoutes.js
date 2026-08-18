const express = require('express');
const { processPayment, getReceipt } = require('../controllers/paymentController');
const router = express.Router();

router.post('/pay', processPayment);
router.get('/receipt/:requestId', getReceipt);

module.exports = router;
