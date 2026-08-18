import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int requestId;
  final double amount;

  const PaymentScreen({super.key, required this.requestId, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  String _selectedMethod = 'pix'; // 'pix', 'credit_card', 'debit_card', 'cash', 'wallet'
  bool _isProcessing = false;
  Map<String, dynamic>? _receiptData;

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    final res = await _apiService.processPayment(widget.requestId, _selectedMethod, widget.amount);
    setState(() {
      _isProcessing = false;
      _receiptData = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento do Chamado #${widget.requestId}'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: _receiptData != null ? _buildReceiptView() : _buildPaymentOptionsView(),
    );
  }

  Widget _buildPaymentOptionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Amount Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Valor Total do Atendimento', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  'R\$ ${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Manutenção de Celular - Substituição de Tela', style: TextStyle(color: Colors.amber, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Selecione a Forma de Pagamento:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
          const SizedBox(height: 12),

          // Payment Methods Radio
          _methodTile('pix', 'PIX (Aprovação Instantânea)', Icons.pix, Colors.teal),
          _methodTile('credit_card', 'Cartão de Crédito', Icons.credit_card, Colors.blue),
          _methodTile('debit_card', 'Cartão de Débito', Icons.payment, Colors.orange),
          _methodTile('cash', 'Dinheiro (Ao final do atendimento)', Icons.attach_money, Colors.green),
          _methodTile('wallet', 'Carteira Digital (PicPay / Mercado Pago)', Icons.account_balance_wallet, Colors.purple),

          const SizedBox(height: 20),

          // If PIX selected show QR preview
          if (_selectedMethod == 'pix') ...[
            Card(
              color: Colors.teal[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.teal[300]!)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2, size: 100, color: Colors.teal),
                    const SizedBox(height: 8),
                    const Text('Escaneie o QR Code ou copie a chave abaixo:', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    SelectableText(
                      '00020126580014BR.GOV.BCB.PIX0136shopmkt-pix-key-9988112252040000',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar Pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _methodTile(String value, String title, IconData icon, Color color) {
    final isSelected = _selectedMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[200]!, width: isSelected ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5)) : null,
        onTap: () => setState(() => _selectedMethod = value),
      ),
    );
  }

  // Comprovante Eletrônico
  Widget _buildReceiptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Comprovante Eletrônico de Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                const Text('ShopMKT Assistência Domiciliar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),
                const Divider(),
                _receiptRow('Código do Comprovante', _receiptData!['receipt_code'] as String),
                _receiptRow('Status', 'PAGO ✓', isGreen: true),
                _receiptRow('Forma de Pagamento', _selectedMethod.toUpperCase()),
                _receiptRow('Data', _receiptData!['date'].toString().substring(0, 19)),
                _receiptRow('Valor Total', 'R\$ ${widget.amount.toStringAsFixed(2)}', isBold: true),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                    child: const Text('Concluído / Voltar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isGreen ? Colors.green[700] : (isBold ? const Color(0xFF4F46E5) : Colors.black87),
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
