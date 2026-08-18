import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final bool initialIsPro;
  const RegisterScreen({super.key, this.initialIsPro = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late bool isPro;
  final _formKey = GlobalKey<FormState>();

  // Common controllers
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // Professional controllers
  final _docIdController = TextEditingController();
  final _operationAreaController = TextEditingController(text: 'Manutenção de Celulares e Eletrônicos');
  final _resumeController = TextEditingController();
  final _certificationsController = TextEditingController();

  bool _hasDocPhoto = true;
  bool _hasResidenceProof = true;
  bool _hasProfilePhoto = true;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isPro = widget.initialIsPro;
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.registerUser(
        name: _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        address: _addressController.text.trim(),
        role: isPro ? 'professional' : 'client',
        documentId: _docIdController.text.trim(),
        operationArea: _operationAreaController.text.trim(),
        resume: _resumeController.text.trim(),
        certifications: _certificationsController.text.trim(),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()), backgroundColor: Colors.red));
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPro
              ? 'Cadastro de profissional enviado! Seus documentos passarão por análise antes da aprovação.'
              : 'Cadastro realizado com sucesso! Bem-vindo ao ShopMKT.',
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isPro ? 'Cadastro de Profissional' : 'Cadastro de Cliente'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPro ? Colors.amber[50] : Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isPro ? Colors.amber[300]! : Colors.indigo[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPro ? Icons.badge_outlined : Icons.person_outline,
                      color: isPro ? Colors.amber[900] : const Color(0xFF4F46E5),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? 'Perfil do Prestador de Serviço' : 'Perfil do Cliente Solicitante',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            isPro
                                ? 'Cadastre suas qualificações e envie comprovantes para validação.'
                                : 'Preencha seus dados para solicitar atendimentos rapidamente.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Dados Pessoais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo *', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(labelText: isPro ? 'CPF ou CNPJ *' : 'CPF *', prefixIcon: const Icon(Icons.badge)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone / WhatsApp *', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail *', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha *', prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço Principal', prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 24),

              // Seção adicional para profissional
              if (isPro) ...[
                const Divider(),
                const SizedBox(height: 12),
                const Text('Documentação & Análise Cadastral', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _docIdController,
                  decoration: const InputDecoration(labelText: 'Número do RG / CNH *', prefixIcon: Icon(Icons.assignment_ind)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _operationAreaController,
                  decoration: const InputDecoration(labelText: 'Área principal de atuação *', prefixIcon: Icon(Icons.build)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _resumeController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Resumo da Experiência Profissional', prefixIcon: Icon(Icons.work_history)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(labelText: 'Certificações / Cursos (Opcional)', prefixIcon: Icon(Icons.workspace_premium)),
                ),
                const SizedBox(height: 16),

                // Uploads / Envio de Documentos (Mock interativo)
                const Text('Anexo de Documentos Requeridos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Foto do Documento de Identificação (Frente e Verso)'),
                        value: _hasDocPhoto,
                        onChanged: (val) => setState(() => _hasDocPhoto = val),
                        secondary: const Icon(Icons.camera_alt),
                      ),
                      SwitchListTile(
                        title: const Text('Foto de Perfil Profissional'),
                        value: _hasProfilePhoto,
                        onChanged: (val) => setState(() => _hasProfilePhoto = val),
                        secondary: const Icon(Icons.account_circle),
                      ),
                      SwitchListTile(
                        title: const Text('Comprovante de Residência Atualizado'),
                        value: _hasResidenceProof,
                        onChanged: (val) => setState(() => _hasResidenceProof = val),
                        secondary: const Icon(Icons.receipt_long),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Botão Cadastrar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPro ? Colors.amber[800] : const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isPro ? 'Enviar Cadastro para Análise' : 'Finalizar Cadastro de Cliente',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
