const express = require('express');
const {
  listCategories,
  createRequest,
  listRequests,
  getRequestById,
  acceptRequest,
  updateStatus
} = require('../controllers/serviceController');
const router = express.Router();

router.get('/categories', listCategories);
router.get('/requests', listRequests);
router.post('/requests', createRequest);
router.get('/requests/:id', getRequestById);
router.post('/requests/:requestId/accept', acceptRequest);
router.put('/requests/:requestId/status', updateStatus);

module.exports = router;

