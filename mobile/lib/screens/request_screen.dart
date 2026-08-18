import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tracking_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController(text: 'Av. Paulista, 1000 - São Paulo, SP');
  String _selectedProblem = 'Tela quebrada';
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    setState(() => _isLoading = true);
    try {
      final user = _apiService.currentUser;
      final userId = (user != null && user['id'] != null) ? (user['id'] as int) : 1;

      final res = await _apiService.createServiceRequest(
        userId: userId,
        categoryId: 1,
        categoryName: 'Celular',
        problem: _selectedProblem,
        description: _descriptionController.text.isEmpty ? 'Solicitação técnica' : _descriptionController.text,
        photos: [],
        address: _addressController.text,
        scheduledAt: '',
        estimatedPrice: 150.00,
      );

      if (!mounted) return;
      final requestId = res['requestId'] as int;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação criada com sucesso!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrackingScreen(requestId: requestId)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Serviço'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Problema', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProblem,
              items: const [
                DropdownMenuItem(value: 'Tela quebrada', child: Text('Tela quebrada')),
                DropdownMenuItem(value: 'Troca de bateria', child: Text('Troca de bateria')),
                DropdownMenuItem(value: 'Não liga', child: Text('Não liga')),
                DropdownMenuItem(value: 'Molhou', child: Text('Molhou')),
                DropdownMenuItem(value: 'Problema de software', child: Text('Problema de software')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProblem = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descreva o problema aqui...',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Endereço de Atendimento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Rua, número, bairro',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar solicitação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

