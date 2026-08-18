const express = require('express');
const { getChatHistory, sendMessage } = require('../controllers/chatController');
const router = express.Router();

router.get('/:requestId', getChatHistory);
router.post('/:requestId', sendMessage);

module.exports = router;
