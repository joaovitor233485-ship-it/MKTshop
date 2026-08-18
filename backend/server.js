const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    project: 'ShopMKT',
    message: 'API backend para plataforma de serviços técnicos e assistência domiciliar'
  });
});

// Rotas iniciais de exemplo
app.post('/auth/register', (req, res) => {
  const { type } = req.body;
  res.json({ status: 'success', type, message: 'Registro recebido. Implementar persistência.' });
});

app.post('/auth/login', (req, res) => {
  res.json({ status: 'success', message: 'Login recebido. Implementar autenticação.' });
});

app.get('/services', (req, res) => {
  res.json({
    categories: [
      'Celular',
      'Notebook',
      'Computador',
      'Videogame',
      'Móveis',
      'TV',
      'Elétrica',
      'Hidráulica'
    ]
  });
});

app.listen(port, () => {
  console.log(`Servidor backend rodando em http://localhost:${port}`);
});
