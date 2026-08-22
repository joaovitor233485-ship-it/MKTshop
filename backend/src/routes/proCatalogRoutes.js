const express = require('express');
const router = express.Router();
const proCatalogController = require('../controllers/proCatalogController');

// Categorias gerais
router.get('/categories', proCatalogController.listCategories);

// Perfil de áreas do profissional
router.put('/:proId/categories', proCatalogController.updateProProfileCategories);

// Serviços do profissional
router.get('/:proId/services', proCatalogController.listProServices);
router.post('/:proId/services', proCatalogController.createProService);
router.put('/:proId/services/:id', proCatalogController.updateProService);
router.delete('/:proId/services/:id', proCatalogController.deleteProService);

// Produtos e peças do profissional
router.get('/:proId/products', proCatalogController.listProProducts);
router.post('/:proId/products', proCatalogController.createProProduct);
router.put('/:proId/products/:id', proCatalogController.updateProProduct);
router.delete('/:proId/products/:id', proCatalogController.deleteProProduct);

// Gerador de itens padrão (Seed)
router.post('/:proId/seed', proCatalogController.seedProDefaults);

module.exports = router;
