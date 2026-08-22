import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProCatalogScreen extends StatefulWidget {
  final bool isEmbedded;
  const ProCatalogScreen({super.key, this.isEmbedded = false});

  @override
  State<ProCatalogScreen> createState() => _ProCatalogScreenState();
}

class _ProCatalogScreenState extends State<ProCatalogScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCatalog();
  }

  int get _proId {
    return _apiService.currentUser?['id'] as int? ?? 2;
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _apiService.getCategories();
      final svcs = await _apiService.getProServices(_proId);
      final prods = await _apiService.getProProducts(_proId);

      if (mounted) {
        setState(() {
          _categories = cats;
          _services = svcs;
          _products = prods;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar catálogo do profissional: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // MODAL NOVO / EDITAR SERVIÇO
  Future<void> _showServiceDialog([Map<String, dynamic>? service]) async {
    final isEdit = service != null;
    final nameController = TextEditingController(text: service?['name'] ?? '');
    final descController = TextEditingController(text: service?['description'] ?? '');
    final priceController = TextEditingController(text: service != null ? '${service['price']}' : '120.00');
    final timeController = TextEditingController(text: service?['estimated_time'] ?? '1 hora');
    int selectedCatId = service?['category_id'] as int? ?? (_categories.isNotEmpty ? _categories.first['id'] as int : 1);
    String status = service?['status'] ?? 'active';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Editar Serviço' : 'Novo Serviço', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome do Serviço *', hintText: 'Ex: Troca de Tela, Formatação'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedCatId,
                      decoration: const InputDecoration(labelText: 'Categoria *'),
                      items: _categories.map((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(c['name']?.toString() ?? 'Geral'),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCatId = val ?? 1),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: r'Preço (R$) *', prefixText: r'R$ '),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Tempo Estimado', hintText: 'Ex: 45 min, 2 horas'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descrição Detalhada'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status do Serviço:'),
                        Switch(
                          value: status == 'active',
                          activeColor: Colors.green,
                          onChanged: (val) => setModalState(() => status = val ? 'active' : 'inactive'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);

                    final payload = {
                      'category_id': selectedCatId,
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'price': double.tryParse(priceController.text.trim()) ?? 100.0,
                      'estimated_time': timeController.text.trim(),
                      'status': status,
                    };

                    if (isEdit) {
                      await _apiService.updateProService(_proId, service['id'] as int, payload);
                    } else {
                      await _apiService.createProService(_proId, payload);
                    }
                    _loadCatalog();
                  },
                  child: Text(isEdit ? 'Salvar' : 'Cadastrar', style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // MODAL NOVO / EDITAR PRODUTO
  Future<void> _showProductDialog([Map<String, dynamic>? product]) async {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final descController = TextEditingController(text: product?['description'] ?? '');
    final priceController = TextEditingController(text: product != null ? '${product['price']}' : '150.00');
    final stockController = TextEditingController(text: product != null ? '${product['stock']}' : '5');
    final brandController = TextEditingController(text: product?['brand'] ?? '');
    final modelController = TextEditingController(text: product?['compatible_model'] ?? '');
    int selectedCatId = product?['category_id'] as int? ?? (_categories.isNotEmpty ? _categories.first['id'] as int : 1);
    String status = product?['status'] ?? 'active';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Editar Produto/Peça' : 'Novo Produto/Peça', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome do Componente *', hintText: 'Ex: Tela iPhone 11, Bateria'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedCatId,
                      decoration: const InputDecoration(labelText: 'Categoria *'),
                      items: _categories.map((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(c['name']?.toString() ?? 'Geral'),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCatId = val ?? 1),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: r'Preço (R$)', prefixText: r'R$ '),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Estoque'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Marca', hintText: 'Ex: Samsung, Apple, Kingston'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Modelo Compatível', hintText: 'Ex: iPhone 11 / Galaxy A52'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descrição Detalhada'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status do Produto:'),
                        Switch(
                          value: status == 'active',
                          activeColor: Colors.green,
                          onChanged: (val) => setModalState(() => status = val ? 'active' : 'inactive'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);

                    final payload = {
                      'category_id': selectedCatId,
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'price': double.tryParse(priceController.text.trim()) ?? 100.0,
                      'stock': int.tryParse(stockController.text.trim()) ?? 0,
                      'brand': brandController.text.trim(),
                      'compatible_model': modelController.text.trim(),
                      'status': status,
                    };

                    if (isEdit) {
                      await _apiService.updateProProduct(_proId, product['id'] as int, payload);
                    } else {
                      await _apiService.createProProduct(_proId, payload);
                    }
                    _loadCatalog();
                  },
                  child: Text(isEdit ? 'Salvar' : 'Cadastrar', style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                color: const Color(0xFF1E1B4B),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.amber,
                        labelColor: Colors.amber,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: 'Serviços Prestados', icon: Icon(Icons.build)),
                          Tab(text: 'Peças & Estoque', icon: Icon(Icons.inventory_2)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.amber),
                      tooltip: 'Carregar Sugestões Rápidas',
                      onPressed: () async {
                        await _apiService.seedProDefaults(_proId, 1);
                        _loadCatalog();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sugestões de serviços e peças carregadas!'), backgroundColor: Colors.green),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildServicesTab(),
                    _buildProductsTab(),
                  ],
                ),
              ),
            ],
          );

    if (widget.isEmbedded) {
      return Scaffold(
        body: bodyContent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (_tabController.index == 0) {
              _showServiceDialog();
            } else {
              _showProductDialog();
            }
          },
          backgroundColor: const Color(0xFF4F46E5),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(_tabController.index == 0 ? 'Novo Serviço' : 'Nova Peça', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Serviços & Peças'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            tooltip: 'Carregar Sugestões Automáticas',
            onPressed: () async {
              await _apiService.seedProDefaults(_proId, 1);
              _loadCatalog();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sugestões de serviços e peças carregadas!'), backgroundColor: Colors.green),
                );
              }
            },
          )
        ],
      ),
      body: bodyContent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showServiceDialog();
          } else {
            _showProductDialog();
          }
        },
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(_tabController.index == 0 ? 'Novo Serviço' : 'Nova Peça', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildServicesTab() {
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Nenhum serviço cadastrado.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showServiceDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Cadastrar Primeiro Serviço', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final s = _services[index];
        final serviceId = (s['id'] as num?)?.toInt() ?? 0;
        final name = s['name']?.toString() ?? 'Serviço';
        final price = (s['price'] as num?)?.toDouble() ?? 0.0;
        final categoryName = s['category_name']?.toString() ?? 'Geral';
        final estimatedTime = s['estimated_time']?.toString() ?? '1 hora';
        final isActive = s['status'] == 'active';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                Text('R\$ ${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Categoria: $categoryName • ⏱️ $estimatedTime', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                if (s['description'] != null && s['description'].toString().isNotEmpty)
                  Text(s['description'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Ativo' : 'Inativo',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green[900] : Colors.grey[800]),
                  ),
                )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showServiceDialog(s)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _apiService.deleteProService(_proId, serviceId);
                    _loadCatalog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Nenhuma peça/produto cadastrado.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showProductDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Cadastrar Primeira Peça', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        final prodId = (p['id'] as num?)?.toInt() ?? 0;
        final name = p['name']?.toString() ?? 'Produto';
        final price = (p['price'] as num?)?.toDouble() ?? 0.0;
        final stock = (p['stock'] as num?)?.toInt() ?? 0;
        final brand = p['brand']?.toString() ?? '';
        final model = p['compatible_model']?.toString() ?? '';
        final isActive = p['status'] == 'active';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                Text('R\$ ${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Estoque: $stock un. • Marca: ${brand.isNotEmpty ? brand : "Geral"}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                if (model.isNotEmpty) Text('Modelo Compatível: $model', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Disponível' : 'Indisponível',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green[900] : Colors.grey[800]),
                  ),
                )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showProductDialog(p)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _apiService.deleteProProduct(_proId, prodId);
                    _loadCatalog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
