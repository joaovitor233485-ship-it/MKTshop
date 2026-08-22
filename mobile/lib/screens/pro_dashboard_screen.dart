import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';

class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _availableRequests = [];
  List<Map<String, dynamic>> _myActiveJobs = [];
  bool _isLoading = true;

  final Set<int> _locallyAcceptedIds = {};

  @override
  void initState() {
    super.initState();
    _loadProData();
  }

  Future<void> _loadProData() async {
    try {
      final available = await _apiService.getRequests(availableOnly: true);
      final proId = _apiService.currentUser?['id'] as int? ?? 2;
      var myJobs = await _apiService.getRequests(proId: proId);

      // Remover das disponíveis solicitações aceitas nesta sessão
      final filteredAvailable = available.where((r) {
        final id = (r['id'] as num?)?.toInt() ?? 0;
        return !_locallyAcceptedIds.contains(id);
      }).toList();

      // Garantir que solicitações aceitas estejam na aba Meus Atendimentos
      for (final id in _locallyAcceptedIds) {
        if (!myJobs.any((j) => (j['id'] as num?)?.toInt() == id)) {
          final acceptedReq = available.firstWhere(
            (r) => (r['id'] as num?)?.toInt() == id,
            orElse: () => {
              'id': id,
              'category_name': 'Geral',
              'problem': 'Atendimento Aceito',
              'client_name': 'Cliente Exemplo',
              'client_phone': '(11) 99999-1111',
              'address': 'Av. Paulista, 1000 - SP',
              'status': 'assigned',
              'price': 280.0,
            },
          );
          final updatedReq = Map<String, dynamic>.from(acceptedReq);
          updatedReq['status'] = 'assigned';
          updatedReq['professional_id'] = proId;
          myJobs.insert(0, updatedReq);
        }
      }

      if (mounted) {
        setState(() {
          _availableRequests = filteredAvailable;
          _myActiveJobs = myJobs;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do profissional: $e');
      if (mounted) {
        setState(() {
          _availableRequests = [];
          _myActiveJobs = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptJob(int requestId) async {
    final user = _apiService.currentUser ?? {'id': 2, 'name': 'Carlos Técnico', 'phone': '(11) 98888-2222'};
    final proId = user['id'] as int? ?? 2;
    final proName = user['name'] as String? ?? 'Carlos Técnico';
    final proPhone = user['phone'] as String? ?? '(11) 98888-2222';

    try {
      _locallyAcceptedIds.add(requestId);
      final success = await _apiService.acceptRequest(
        requestId,
        proId,
        proName,
        proPhone,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atendimento aceito com sucesso! O cliente foi notificado.'), backgroundColor: Colors.green),
        );
        _loadProData();
      }
    } catch (e) {
      debugPrint('Erro ao aceitar atendimento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aceitar atendimento: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateJobStatus(int requestId, String newStatus) async {
    if (newStatus == 'completed') {
      _showFinishServiceDialog(requestId);
      return;
    }
    final success = await _apiService.updateRequestStatus(requestId, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para "$newStatus".'), backgroundColor: Colors.blue),
      );
      _loadProData();
    }
  }

  Future<void> _showFinishServiceDialog(int requestId) async {
    String selectedPhoto = 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500';
    final customUrlController = TextEditingController();
    final notesController = TextEditingController(text: 'Serviço concluído e testado. Aparelho sem qualquer defeito ou avaria.');

    final samplePhotos = [
      {'label': '📱 Aparelho Reparado', 'url': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500'},
      {'label': '🔧 Manutenção OK', 'url': 'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=500'},
      {'label': '⚡ Testado & Aprovado', 'url': 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500'},
    ];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activePhotoUrl = customUrlController.text.trim().isNotEmpty
                ? customUrlController.text.trim()
                : selectedPhoto;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.camera_alt, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Foto de Comprovação Obrigatória', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tire ou selecione uma foto do aparelho/serviço finalizado. Esta foto será guardada como prova técnica de que o serviço foi entregue com êxito e sem avarias.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),

                    const Text('Selecione uma foto da câmera/galeria:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: samplePhotos.map((photo) {
                        final isSelected = selectedPhoto == photo['url'] && customUrlController.text.trim().isEmpty;
                        return ChoiceChip(
                          label: Text(photo['label']!),
                          selected: isSelected,
                          selectedColor: Colors.green[100],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.green[900] : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedPhoto = photo['url']!;
                                customUrlController.clear();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: customUrlController,
                      decoration: InputDecoration(
                        labelText: 'Ou cole a URL / Base64 da Foto',
                        hintText: 'http://...',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 14),

                    if (activePhotoUrl.isNotEmpty) ...[
                      const Text('Pré-visualização da Prova:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          activePhotoUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Text('Erro ao carregar imagem', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    const Text('Observações / Relatório Técnico:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ex: Aparelho testado por 15min, tela e touch 100% funcionais.',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final photoToSubmit = activePhotoUrl.trim();
                    if (photoToSubmit.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto de comprovação é obrigatória!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(ctx);

                    try {
                      final success = await _apiService.updateRequestStatus(
                        requestId,
                        'completed',
                        completionPhotos: [photoToSubmit],
                        completionNotes: notesController.text.trim(),
                      );

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Serviço finalizado com sucesso! Foto de comprovação salva como garantia.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadProData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao finalizar: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Confirmar e Finalizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.badge, color: Colors.amber),
              SizedBox(width: 8),
              Text('ShopMKT — Área do Profissional'),
            ],
          ),
          backgroundColor: const Color(0xFF1E1B4B),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Solicitações Disponíveis', icon: Icon(Icons.notifications_active)),
              Tab(text: 'Meus Atendimentos', icon: Icon(Icons.assignment_turned_in)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAvailableFeed(),
                  _buildMyJobsList(),
                ],
              ),
      ),
    );
  }

  double _safeParsePrice(dynamic raw) {
    if (raw == null) return 280.0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 280.0;
  }

  // Feed de Chamados Disponíveis na Região
  Widget _buildAvailableFeed() {
    if (_availableRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Nenhuma solicitação pendente no momento.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Novos chamados aparecerão em tempo real.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableRequests.length,
      itemBuilder: (context, index) {
        final req = _availableRequests[index];
        final reqId = (req['id'] as num?)?.toInt() ?? 0;
        final categoryName = req['category_name']?.toString() ?? 'Geral';
        final problem = req['problem']?.toString() ?? 'Solicitação de Serviço';
        final description = req['description']?.toString() ?? 'Sem descrição detalhada.';
        final clientName = req['client_name']?.toString() ?? 'Cliente';
        final address = req['address']?.toString() ?? 'Endereço não informado';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        categoryName,
                        style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.near_me, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('1.8 km de você', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(problem, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('Cliente: $clientName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(address, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valor Estimado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          'R\$ ${_safeParsePrice(req['price']).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Recusar', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _acceptJob(reqId),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                          child: const Text('Aceitar Atendimento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Meus Atendimentos Ativos com Botões de Status
  Widget _buildMyJobsList() {
    if (_myActiveJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Você não possui atendimentos ativos.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Aceite solicitações na aba "Solicitações Disponíveis".', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myActiveJobs.length,
      itemBuilder: (context, index) {
        final job = _myActiveJobs[index];
        final jobId = (job['id'] as num?)?.toInt() ?? 0;
        final categoryName = job['category_name']?.toString() ?? 'Geral';
        final problem = job['problem']?.toString() ?? 'Solicitação de Serviço';
        final clientName = job['client_name']?.toString() ?? 'Cliente';
        final clientPhone = job['client_phone']?.toString() ?? '';
        final address = job['address']?.toString() ?? 'Endereço não informado';
        final status = job['status']?.toString() ?? 'pending';
        final completionPhotos = job['completion_photos'] as List? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chamado #$jobId — $categoryName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFF4F46E5)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              requestId: jobId,
                              proName: clientName,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
                Text('Problema: $problem', style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('Cliente: $clientName • $clientPhone', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text('Endereço: $address', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 14),

                if (completionPhotos.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Colors.green, size: 18),
                        SizedBox(width: 6),
                        Text('Foto de comprovação registrada no sistema', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const Text('Atualizar Estágio do Atendimento:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 8),

                // Status Buttons Bar
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _statusBtn(jobId, 'on_the_way', 'Em Deslocamento', status == 'on_the_way'),
                    _statusBtn(jobId, 'arrived', 'Cheguei ao Local', status == 'arrived'),
                    _statusBtn(jobId, 'in_progress', 'Em Andamento', status == 'in_progress'),
                    _statusBtn(jobId, 'completed', 'Finalizar Serviço', status == 'completed', isGreen: true),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBtn(int requestId, String statusKey, String label, bool isActive, {bool isGreen = false}) {
    return ElevatedButton(
      onPressed: () => _updateJobStatus(requestId, statusKey),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? (isGreen ? Colors.green[700] : const Color(0xFF4F46E5)) : Colors.grey[200],
        foregroundColor: isActive ? Colors.white : Colors.grey[800],
        elevation: isActive ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
