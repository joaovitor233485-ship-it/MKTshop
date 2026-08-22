const pool = require('../config/db');

// Listar todas as categorias ativas
const listCategories = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, name, description, active FROM service_categories WHERE active = 1 ORDER BY id');
    res.json({ status: 'success', categories: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao buscar categorias.' });
  }
};

// Atualizar áreas de atuação do profissional
const updateProProfileCategories = async (req, res) => {
  try {
    const { proId } = req.params;
    const { operation_area } = req.body;

    if (!operation_area) {
      return res.status(400).json({ status: 'error', message: 'Área de atuação é obrigatória.' });
    }

    await pool.execute(
      'UPDATE users SET operation_area = ? WHERE id = ?',
      [operation_area, proId]
    );

    res.json({ status: 'success', message: 'Área de atuação atualizada com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao atualizar área de atuação.' });
  }
};

// --- GESTÃO DE SERVIÇOS DO PROFISSIONAL ---

const listProServices = async (req, res) => {
  try {
    const { proId } = req.params;
    const [rows] = await pool.execute(
      `SELECT s.id, s.professional_id, s.category_id, s.name, s.description, s.price, 
              s.estimated_time, s.status, s.created_at,
              c.name AS category_name
       FROM pro_services s
       LEFT JOIN service_categories c ON c.id = s.category_id
       WHERE s.professional_id = ?
       ORDER BY s.id DESC`,
      [proId]
    );
    res.json({ status: 'success', services: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao listar serviços do profissional.' });
  }
};

const createProService = async (req, res) => {
  try {
    const { proId } = req.params;
    const { category_id, name, description, price, estimated_time, status } = req.body;

    if (!name || !category_id || price === undefined) {
      return res.status(400).json({ status: 'error', message: 'Nome, categoria e preço são obrigatórios.' });
    }

    const catId = parseInt(category_id, 10);
    const parsedPrice = parseFloat(price) || 0.0;
    const timeEst = estimated_time || '1 hora';
    const st = status || 'active';
    const desc = description || '';

    const [result] = await pool.execute(
      `INSERT INTO pro_services 
        (professional_id, category_id, name, description, price, estimated_time, status)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [proId, catId, name, desc, parsedPrice, timeEst, st]
    );

    res.status(201).json({
      status: 'success',
      message: 'Serviço cadastrado com sucesso!',
      serviceId: result.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao cadastrar serviço.' });
  }
};

const updateProService = async (req, res) => {
  try {
    const { proId, id } = req.params;
    const { category_id, name, description, price, estimated_time, status } = req.body;

    if (!name || !category_id || price === undefined) {
      return res.status(400).json({ status: 'error', message: 'Nome, categoria e preço são obrigatórios.' });
    }

    const catId = parseInt(category_id, 10);
    const parsedPrice = parseFloat(price) || 0.0;
    const timeEst = estimated_time || '1 hora';
    const st = status || 'active';
    const desc = description || '';

    const [result] = await pool.execute(
      `UPDATE pro_services 
       SET category_id = ?, name = ?, description = ?, price = ?, estimated_time = ?, status = ?
       WHERE id = ? AND professional_id = ?`,
      [catId, name, desc, parsedPrice, timeEst, st, id, proId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Serviço não encontrado ou não pertence a este profissional.' });
    }

    res.json({ status: 'success', message: 'Serviço atualizado com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao atualizar serviço.' });
  }
};

const deleteProService = async (req, res) => {
  try {
    const { proId, id } = req.params;

    const [result] = await pool.execute(
      'DELETE FROM pro_services WHERE id = ? AND professional_id = ?',
      [id, proId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Serviço não encontrado ou não pertence a este profissional.' });
    }

    res.json({ status: 'success', message: 'Serviço excluído com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao excluir serviço.' });
  }
};

// --- GESTÃO DE PRODUTOS E PEÇAS DO PROFISSIONAL ---

const listProProducts = async (req, res) => {
  try {
    const { proId } = req.params;
    const [rows] = await pool.execute(
      `SELECT p.id, p.professional_id, p.category_id, p.name, p.description, p.price, 
              p.stock, p.brand, p.compatible_model, p.status, p.created_at,
              c.name AS category_name
       FROM pro_products p
       LEFT JOIN service_categories c ON c.id = p.category_id
       WHERE p.professional_id = ?
       ORDER BY p.id DESC`,
      [proId]
    );
    res.json({ status: 'success', products: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao listar produtos/peças do profissional.' });
  }
};

const createProProduct = async (req, res) => {
  try {
    const { proId } = req.params;
    const { category_id, name, description, price, stock, brand, compatible_model, status } = req.body;

    if (!name || !category_id || price === undefined) {
      return res.status(400).json({ status: 'error', message: 'Nome do produto, categoria e preço são obrigatórios.' });
    }

    const catId = parseInt(category_id, 10);
    const parsedPrice = parseFloat(price) || 0.0;
    const parsedStock = parseInt(stock, 10) || 0;
    const br = brand || '';
    const compModel = compatible_model || '';
    const st = status || 'active';
    const desc = description || '';

    const [result] = await pool.execute(
      `INSERT INTO pro_products 
        (professional_id, category_id, name, description, price, stock, brand, compatible_model, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [proId, catId, name, desc, parsedPrice, parsedStock, br, compModel, st]
    );

    res.status(201).json({
      status: 'success',
      message: 'Produto/Peça cadastrada com sucesso!',
      productId: result.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao cadastrar produto.' });
  }
};

const updateProProduct = async (req, res) => {
  try {
    const { proId, id } = req.params;
    const { category_id, name, description, price, stock, brand, compatible_model, status } = req.body;

    if (!name || !category_id || price === undefined) {
      return res.status(400).json({ status: 'error', message: 'Nome do produto, categoria e preço são obrigatórios.' });
    }

    const catId = parseInt(category_id, 10);
    const parsedPrice = parseFloat(price) || 0.0;
    const parsedStock = parseInt(stock, 10) || 0;
    const br = brand || '';
    const compModel = compatible_model || '';
    const st = status || 'active';
    const desc = description || '';

    const [result] = await pool.execute(
      `UPDATE pro_products 
       SET category_id = ?, name = ?, description = ?, price = ?, stock = ?, brand = ?, compatible_model = ?, status = ?
       WHERE id = ? AND professional_id = ?`,
      [catId, name, desc, parsedPrice, parsedStock, br, compModel, st, id, proId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Produto não encontrado ou não pertence a este profissional.' });
    }

    res.json({ status: 'success', message: 'Produto/Peça atualizada com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao atualizar produto.' });
  }
};

const deleteProProduct = async (req, res) => {
  try {
    const { proId, id } = req.params;

    const [result] = await pool.execute(
      'DELETE FROM pro_products WHERE id = ? AND professional_id = ?',
      [id, proId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', message: 'Produto não encontrado ou não pertence a este profissional.' });
    }

    res.json({ status: 'success', message: 'Produto/Peça excluída com sucesso!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao excluir produto.' });
  }
};

// --- GERADOR DE TEMPLATES POPULARES (SEED) ---
const seedProDefaults = async (req, res) => {
  try {
    const { proId } = req.params;
    const { categoryId } = req.body;

    const catId = parseInt(categoryId || 1, 10);

    const defaultServices = {
      1: [ // Celular
        { name: 'Troca de tela', price: 250.00, estimated_time: '1 hora', description: 'Substituição completa de display e touch original/premium' },
        { name: 'Troca de bateria', price: 150.00, estimated_time: '45 minutos', description: 'Troca de bateria viciada por nova com saúde 100%' },
        { name: 'Troca de conector de carga', price: 120.00, estimated_time: '1 hora', description: 'Limpeza ou substituição do conector de carga Tipo C / Lightning' },
        { name: 'Formatação e Restauração', price: 80.00, estimated_time: '30 minutos', description: 'Reinstalação limpa do sistema operando com restauração de fábrica' },
        { name: 'Diagnóstico e Limpeza Técnica', price: 30.00, estimated_time: '20 minutos', description: 'Avaliação presencial de placas e limpeza de conectores/alto-falantes' }
      ],
      2: [ // Computador/Notebook
        { name: 'Formatação com Backup', price: 120.00, estimated_time: '2 horas', description: 'Instalação do Windows/Linux com backup de arquivos e programas essenciais' },
        { name: 'Instalação do Windows + Drivers', price: 90.00, estimated_time: '1 hora', description: 'Reinstalação do sistema operacional com otimização' },
        { name: 'Limpeza interna + Pasta Térmica', price: 110.00, estimated_time: '1h 30m', description: 'Desmontagem, limpeza de poeira dos coolers e troca de pasta térmica Silver' },
        { name: 'Upgrade de memória RAM', price: 60.00, estimated_time: '30 minutos', description: 'Instalação e teste de compatibilidade de novos pentes de memória' },
        { name: 'Instalação de SSD NVMe/SATA', price: 80.00, estimated_time: '1 hora', description: 'Instalação física de SSD e clonagem do sistema antigo' },
        { name: 'Manutenção preventiva geral', price: 150.00, estimated_time: '2 horas', description: 'Revisão geral de hardware, testes de estresse e limpeza técnica' }
      ],
      6: [ // Eletricista
        { name: 'Instalação de tomada / interruptor', price: 80.00, estimated_time: '40 minutos', description: 'Instalação de ponto elétrico residencial com padrão NBR' },
        { name: 'Instalação de ventilador de teto', price: 150.00, estimated_time: '1h 30m', description: 'Montagem, fixação no teto e ligação elétrica do ventilador e controle' },
        { name: 'Instalação de luminária / Lustre', price: 100.00, estimated_time: '1 hora', description: 'Fixação e ligação de luminárias LED, plafons e lustres' },
        { name: 'Troca de disjuntor em quadro', price: 90.00, estimated_time: '45 minutos', description: 'Substituição de disjuntor queimado ou dimensionamento inadequado' }
      ],
      7: [ // Encanador
        { name: 'Desentupimento de pia / ralo', price: 120.00, estimated_time: '1 hora', description: 'Desobstrução de encanamento de pia de cozinha, lavatório ou ralo' },
        { name: 'Troca de sifão e engate flexível', price: 70.00, estimated_time: '30 minutos', description: 'Troca de vedações e tubulação de escoamento' },
        { name: 'Reparo de vazamento hidráulico', price: 160.00, estimated_time: '2 horas', description: 'Localização e conserto de vazamentos aparentes em canos PVC/PPR' },
        { name: 'Instalação de vaso sanitário', price: 180.00, estimated_time: '2 horas', description: 'Instalação de vaso com caixa acoplada, anel de vedação e engate' }
      ],
      5: [ // Montador de móveis
        { name: 'Montagem de guarda-roupa 6 portas', price: 220.00, estimated_time: '3 horas', description: 'Montagem completa de guarda-roupas de grande porte' },
        { name: 'Montagem de painel de TV', price: 120.00, estimated_time: '1h 30m', description: 'Montagem e fixação firme do painel na parede com passagem de cabos' },
        { name: 'Montagem de mesa de escritório / escrivaninha', price: 90.00, estimated_time: '1 hora', description: 'Montagem de mesas e gaveteiros' }
      ]
    };

    const defaultProducts = {
      1: [ // Celular
        { name: 'Tela de iPhone (Linha 11/12/13)', price: 280.00, stock: 10, brand: 'Apple Compatible', compatible_model: 'iPhone 11/12/13', description: 'Display OLED com alta nitidez' },
        { name: 'Tela de Samsung (Linha A / S)', price: 230.00, stock: 8, brand: 'Samsung Original', compatible_model: 'Galaxy A32/A52/S20', description: 'Tela Super AMOLED com aro' },
        { name: 'Bateria de Smartphone Premium', price: 120.00, stock: 15, brand: 'Gold Tech', compatible_model: 'iPhone / Android', description: 'Bateria com 100% de capacidade' },
        { name: 'Conector de Carga Tipo C', price: 40.00, stock: 25, brand: 'Foxconn', compatible_model: 'Android Geral', description: 'Flex de carga rápida' },
        { name: 'Película 3D de Vidro Temperado', price: 25.00, stock: 50, brand: 'Havit', compatible_model: 'Modelos Variados', description: 'Proteção contra impactos' }
      ],
      2: [ // Computador
        { name: 'SSD Kingston NVMe 512GB', price: 260.00, stock: 6, brand: 'Kingston', compatible_model: 'Slot M.2 2280', description: 'Ultra velocidade de leitura 3500MB/s' },
        { name: 'Memória RAM DDR4 8GB Corsair', price: 150.00, stock: 10, brand: 'Corsair', compatible_model: 'DDR4 2666MHz / 3200MHz', description: 'Pente de memória para PC / Notebook' },
        { name: 'Pasta Térmica Prata Arctic MX-4', price: 50.00, stock: 15, brand: 'Arctic', compatible_model: 'CPUs e GPUs', description: 'Seringa de pasta térmica de alto desempenho' }
      ]
    };

    const servicesToInsert = defaultServices[catId] || defaultServices[1];
    const productsToInsert = defaultProducts[catId] || defaultProducts[1];

    for (const svc of servicesToInsert) {
      await pool.execute(
        `INSERT INTO pro_services (professional_id, category_id, name, description, price, estimated_time, status)
         VALUES (?, ?, ?, ?, ?, ?, 'active')`,
        [proId, catId, svc.name, svc.description, svc.price, svc.estimated_time]
      );
    }

    for (const prod of productsToInsert) {
      await pool.execute(
        `INSERT INTO pro_products (professional_id, category_id, name, description, price, stock, brand, compatible_model, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')`,
        [proId, catId, prod.name, prod.description, prod.price, prod.stock, prod.brand, prod.compatible_model]
      );
    }

    res.json({
      status: 'success',
      message: `Cadastrados ${servicesToInsert.length} serviços e ${productsToInsert.length} produtos padrão com sucesso!`
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status: 'error', message: 'Erro ao gerar itens padrão.' });
  }
};

module.exports = {
  listCategories,
  updateProProfileCategories,
  listProServices,
  createProService,
  updateProService,
  deleteProService,
  listProProducts,
  createProProduct,
  updateProProduct,
  deleteProProduct,
  seedProDefaults
};
