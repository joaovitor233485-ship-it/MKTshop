import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final int requestId;
  final int proId;
  final String proName;

  const ReviewScreen({
    super.key,
    required this.requestId,
    required this.proId,
    required this.proName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ApiService _apiService = ApiService();

  int _quality = 5;
  int _punctuality = 5;
  int _politeness = 5;
  int _organization = 5;
  int _speed = 5;
  final _commentController = TextEditingController(text: 'Excelente atendimento! Profissional muito atencioso e resolveu rapidamente.');

  Future<void> _submit() async {
    await _apiService.submitReview(
      requestId: widget.requestId,
      userId: _apiService.currentUser?['id'] as int? ?? 0,
      proId: widget.proId,
      quality: _quality,
      punctuality: _punctuality,
      politeness: _politeness,
      organization: _organization,
      speed: _speed,
      comment: _commentController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação registrada com sucesso! Obrigado pelo feedback.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Atendimento'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pro Header Card
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF4F46E5),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.proName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Atendimento de Manutenção de Celular', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Avalie o profissional nos 5 critérios:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
            const SizedBox(height: 16),

            _starRatingRow('Qualidade do Serviço', _quality, (val) => setState(() => _quality = val)),
            _starRatingRow('Pontualidade', _punctuality, (val) => setState(() => _punctuality = val)),
            _starRatingRow('Educação / Cordialidade', _politeness, (val) => setState(() => _politeness = val)),
            _starRatingRow('Organização / Limpeza', _organization, (val) => setState(() => _organization = val)),
            _starRatingRow('Rapidez na Execução', _speed, (val) => setState(() => _speed = val)),

            const SizedBox(height: 20),
            const Text('Deixe um comentário sobre sua experiência:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escreva detalhes sobre a qualidade do atendimento...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Enviar Avaliação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _starRatingRow(String label, int currentRating, Function(int) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Row(
            children: List.generate(5, (index) {
              final starNum = index + 1;
              return GestureDetector(
                onTap: () => onSelect(starNum),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    starNum <= currentRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
