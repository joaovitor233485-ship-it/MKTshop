const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const userRoutes = require('./routes/userRoutes');
const adminRoutes = require('./routes/adminRoutes');
const chatRoutes = require('./routes/chatRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const proCatalogRoutes = require('./routes/proCatalogRoutes');

const app = express();

// Normalize paths when running behind Netlify Functions which forward requests as '/.netlify/functions/server/...'
app.use((req, res, next) => {
  if (req.url && req.url.startsWith('/.netlify/functions/server')) {
    // strip the prefix so route matching remains the same as local server
    req.url = req.url.replace(/^\/\.netlify\/functions\/server/, '') || '/';
    req.path = req.url; // ensure path is consistent
  }
  next();
});

app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/', (req, res) => {
  res.json({
    project: 'ShopMKT',
    message: 'API backend para plataforma de serviços técnicos e assistência domiciliar'
  });
});

app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/services', serviceRoutes);
app.use('/admin', adminRoutes);
app.use('/chat', chatRoutes);
app.use('/payments', paymentRoutes);
app.use('/reviews', reviewRoutes);
app.use('/pro-catalog', proCatalogRoutes);

app.use((req, res) => {
  res.status(404).json({ status: 'error', message: 'Rota não encontrada' });
});

module.exports = app;
