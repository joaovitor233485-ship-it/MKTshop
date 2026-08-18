const express = require('express');
const { getUserById, listUsers } = require('../controllers/userController');
const router = express.Router();

router.get('/', listUsers);
router.get('/:id', getUserById);

module.exports = router;
