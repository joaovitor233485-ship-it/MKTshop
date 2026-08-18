const express = require('express');
const { submitReview, getProReviews } = require('../controllers/reviewController');
const router = express.Router();

router.post('/', submitReview);
router.get('/pro/:professionalId', getProReviews);

module.exports = router;
