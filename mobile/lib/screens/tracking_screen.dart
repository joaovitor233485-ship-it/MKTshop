import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'review_screen.dart';

class TrackingScreen extends StatefulWidget {
  final int requestId;
  const TrackingScreen({super.key, required this.requestId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _requestData;
  bool _isLoading = true;

  Future<void> _openMercadoPagoLink() async {
    final url = Uri.parse('https://link.mercadopago.com.br/shopmkt');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Erro ao abrir link: $e');
    }
  }

  final List<Map<String, dynamic>> _stages = [
    {'key': 'pending', 'label': 'Solicitação enviada', 'desc': 'Procurando profissionais disponíveis'},
    {'key': 'assigned', 'label': 'Profissional encontrado', 'desc': 'Marcos aceitou seu atendimento'},
    {'key': 'on_the_way', 'label': 'Em deslocamento', 'desc': 'Técnico a 1.2 km de distância'},
    {'key': 'arrived', 'label': 'Chegou ao local', 'desc': 'Profissional na recepção/portaria'},
    {'key': 'in_progress', 'label': 'Serviço em andamento', 'desc': 'Realizando conserto da tela'},
    {'key': 'completed', 'label': 'Finalizado', 'desc': 'Serviço concluído e aprovado'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRequest();
  }

  Future<void> _fetchRequest() async {
    try {
      // 1. Tentar buscar diretamente pelo ID da solicitação
      Map<String, dynamic>? req = await _apiService.getRequestById(widget.requestId);

      // 2. Se não encontrar por ID direto, buscar lista do usuário ou geral
      if (req == null) {
        final currentUserId = _apiService.currentUser?['id'] as int?;
        List<Map<String, dynamic>> requests = await _apiService.getRequests(userId: currentUserId);

        if (requests.isEmpty) {
          requests = await _apiService.getRequests();
        }

        if (requests.isNotEmpty) {
          req = requests.firstWhere(
            (r) => r['id'] == widget.requestId,
            orElse: () => requests.first,
          );
        }
      }

      // 3. Fallback padrão se nenhuma solicitação for encontrada
      req ??= {
        'id': widget.requestId,
        'status': 'pending',
        'problem': 'Solicitação de Serviço',
        'category_name': 'Geral',
        'description': 'Solicitação enviada e aguardando profissionais.',
        'address': 'Endereço informado',
        'price': 280.00,
        'client_name': 'Cliente',
        'pro_name': 'Aguardando Profissional',
      };

      if (mounted) {
        setState(() {
          _requestData = req;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar solicitação: $e');
      if (mounted) {
        setState(() {
          _requestData = {
            'id': widget.requestId,
            'status': 'pending',
            'problem': 'Solicitação de Serviço',
            'category_name': 'Geral',
            'description': 'Solicitação enviada com sucesso aos profissionais!',
            'address': 'Endereço informado',
            'price': 280.00,
            'client_name': 'Cliente',
            'pro_name': 'Aguardando Profissional',
          };
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

  int _getCurrentStageIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'assigned':
        return 1;
      case 'on_the_way':
        return 2;
      case 'arrived':
        return 3;
      case 'in_progress':
        return 4;
      case 'completed':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Acompanhamento #${widget.requestId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentStatus = _requestData?['status'] ?? 'pending';
    final currentStageIdx = _getCurrentStageIndex(currentStatus);
    final hasPro = currentStatus != 'pending' && _requestData?['professional_id'] != null;
    final proName = _requestData?['pro_name'] ?? 'Carlos Técnico';
    final categoryName = _requestData?['category_name'] ?? 'Geral';
    final problem = _requestData?['problem'] ?? 'Solicitação de Serviço';
    final address = _requestData?['address'] ?? 'Endereço informado';
    final isCompleted = currentStatus == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: Text('Acompanhamento em Tempo Real #${widget.requestId}'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de aviso quando aguarda confirmação do pagamento
            if (currentStatus == 'awaiting_payment_confirmation') ...[
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.amber[400]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.hourglass_top, color: Colors.amber, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aguardando Confirmação do Pagamento pelo Admin',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF78350F)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Seu pedido foi registrado. Realize o pagamento via Mercado Pago no link oficial abaixo:',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openMercadoPagoLink,
                          icon: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                          label: const Text('Abrir Mercado Pago em Nova Aba', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009EE3),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _openMercadoPagoLink,
                        child: SelectableText(
                          'https://link.mercadopago.com.br/shopmkt',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blue[900],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Professional Badge Card ou Searching Status Clean Card
            if (hasPro) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF4F46E5),
                        child: Text('T', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(proName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('Técnico Especialista • R\$ 280,00', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text('4.9 (128 avaliações)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4F46E5), size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(requestId: widget.requestId, proName: proName),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.radar, color: Color(0xFF4F46E5), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Aguardando Profissional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E1B4B))),
                                SizedBox(height: 2),
                                Text('Sua solicitação está visível aos técnicos próximos.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Categoria: $categoryName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Problema: $problem', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      Text('Local: $address', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Mock Interactive Map Component (Visível apenas após profissional aceitar)
            if (hasPro) ...[
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.map, color: Colors.amber, size: 36),
                            SizedBox(width: 10),
                            Text(
                              'Mapa GPS Integrado',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: Colors.amber, size: 20),
                              SizedBox(width: 6),
                              Text('Tempo estimado: 8 min', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('Distância: 1.2 km', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              'Estágio do Atendimento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 16),

            // Step Timeline Indicator
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stages.length,
              itemBuilder: (context, index) {
                final stage = _stages[index];
                final isPassed = index <= currentStageIdx;
                final isCurrent = index == currentStageIdx;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPassed ? const Color(0xFF4F46E5) : Colors.grey[300],
                            border: isCurrent ? Border.all(color: Colors.amber, width: 3) : null,
                          ),
                          child: Center(
                            child: isPassed
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ),
                        if (index < _stages.length - 1)
                          Container(
                            width: 2,
                            height: 36,
                            color: isPassed ? const Color(0xFF4F46E5) : Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage['label'] as String,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                fontSize: isCurrent ? 15 : 14,
                                color: isPassed ? const Color(0xFF1E1B4B) : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stage['desc'] as String,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Proof Photo Card for Customer
            if (currentStatus == 'completed' || (_requestData?['completion_photos'] != null && (_requestData!['completion_photos'] as List).isNotEmpty)) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                color: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF86EFAC)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified, color: Colors.green, size: 22),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Comprovante de Conclusão Sem Avarias',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF166534)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Foto tirada pelo técnico no momento da finalização como garantia de que o serviço foi entregue com êxito.',
                        style: TextStyle(fontSize: 12, color: Colors.green[800]),
                      ),
                      const SizedBox(height: 12),

                      if ((_requestData?['completion_photos'] as List? ?? []).isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            (_requestData!['completion_photos'] as List).first.toString(),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: const Text('Foto de garantia registrada no servidor', style: TextStyle(fontSize: 12, color: Colors.green)),
                            ),
                          ),
                        ),

                      if (_requestData?['completion_notes'] != null && (_requestData!['completion_notes'] as String).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Observações do Técnico: ${_requestData!['completion_notes']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text('Voltar para a Tela Inicial', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isCompleted
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(requestId: widget.requestId, proId: 2, proName: proName),
                              ),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('A avaliação só pode ser feita após o profissional finalizar o serviço.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                    icon: Icon(Icons.star, color: isCompleted ? Colors.amber : Colors.grey),
                    label: Text(
                      'Avaliar',
                      style: TextStyle(color: isCompleted ? const Color(0xFF4F46E5) : Colors.grey),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: isCompleted ? const Color(0xFF4F46E5) : Colors.grey[300]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
