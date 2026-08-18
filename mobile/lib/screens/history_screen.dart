import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tracking_screen.dart';
import 'payment_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await _apiService.getRequests(userId: _apiService.currentUser?['id']);
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
      });
    }
  }

  double _safeParsePrice(dynamic raw) {
    if (raw == null) return 280.0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 280.0;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'on_the_way':
      case 'arrived':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Concluído';
      case 'in_progress':
        return 'Em andamento';
      case 'on_the_way':
        return 'Em deslocamento';
      case 'arrived':
        return 'Técnico no local';
      case 'assigned':
        return 'Profissional atribuído';
      case 'pending':
        return 'Aguardando atendimento';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Solicitações'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                final status = req['status'] as String;
                final statusColor = _getStatusColor(status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chamado #${req['id']} — ${req['category_name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Problema: ${req['problem']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          'Profissional: ${req['pro_name'] ?? "Aguardando aceitação"}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text('Endereço: ${req['address']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${_safeParsePrice(req['price']).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4F46E5)),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackingScreen(requestId: req['id'] as int),
                                      ),
                                    );
                                  },
                                  child: const Text('Ver Status'),
                                ),
                                if (status == 'completed') ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentScreen(
                                            requestId: req['id'] as int,
                                            amount: _safeParsePrice(req['price']),
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                                    child: const Text('Comprovante', style: TextStyle(color: Colors.white)),
                                  )
                                ]
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
