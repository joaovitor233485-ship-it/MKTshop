import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tracking_screen.dart';

class ServiceRequestWizardScreen extends StatefulWidget {
  final int? selectedCategoryId;
  final String? selectedCategoryName;

  const ServiceRequestWizardScreen({
    super.key,
    this.selectedCategoryId,
    this.selectedCategoryName,
  });

  @override
  State<ServiceRequestWizardScreen> createState() => _ServiceRequestWizardScreenState();
}

class _ServiceRequestWizardScreenState extends State<ServiceRequestWizardScreen> {
  int _currentStep = 0;
  final ApiService _apiService = ApiService();

  // State values across the 7 steps
  int _selectedCategory = 1;
  String _categoryName = 'Celular';
  String _selectedProblem = 'Tela quebrada';
  final _descriptionController = TextEditingController(
    text: 'Meu celular caiu da mesa. Após a queda, a tela ficou totalmente preta e não responde ao toque.',
  );
  List<String> _attachedPhotos = ['foto_tela_danificada.jpg'];
  String _addressType = 'gps'; // 'gps', 'manual', 'favorite'
  final _addressController = TextEditingController(text: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP');
  String _scheduleOption = 'Imediato'; // 'Imediato', 'Hoje', 'Amanhã', 'Personalizado'
  String _selectedTime = '14:30';

  final Map<String, List<String>> _problemsByCategory = {
    'Celular': [
      'Tela quebrada',
      'Troca de bateria',
      'Não liga',
      'Molhou / Danos por água',
      'Problema de software / Loop',
      'Entrada de carregador',
      'Câmera danificada',
      'Alto-falante com ruído'
    ],
    'Notebook': [
      'Lentidão extrema / Formatação',
      'Troca de teclado',
      'Tela trincada / Sem imagem',
      'Bateria viciada / Não carrega',
      'Superaquecimento / Limpeza',
      'Upgrade SSD / Memória RAM'
    ],
    'Computador': [
      'Não liga / Fonte queimada',
      'Montagem de PC Gamer',
      'Vírus e malwares',
      'Placa de vídeo com artefatos',
      'Configuração de rede Wi-Fi'
    ],
    'Videogame': [
      'Limpeza e troca de pasta térmica',
      'Leitor de disco não lê',
      'Luz vermelha / azul da morte',
      'Controle com drift nos analógicos'
    ],
    'Móveis': [
      'Montagem de guarda-roupa',
      'Montagem de painel de TV',
      'Reparo de gavetas e portas',
      'Desmontagem para mudança'
    ],
    'TV': [
      'Instalação de suporte na parede',
      'Sem som / Imagem com faixas',
      'Configuração de Smart TV'
    ],
    'Elétrica': [
      'Instalação de tomadas e disjuntores',
      'Instalação de chuveiro elétrico',
      'Curto-circuito na rede',
      'Troca de fiação residencial'
    ],
    'Hidráulica': [
      'Vazamento em torneira ou cano',
      'Desentupimento de pia / vaso',
      'Instalação de torneira ou filtro'
    ]
  };

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategoryId != null) {
      _selectedCategory = widget.selectedCategoryId!;
      _categoryName = widget.selectedCategoryName ?? 'Celular';
      _selectedProblem = _problemsByCategory[_categoryName]?.first ?? 'Outro problema';
    }
  }

  void _nextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
    } else {
      _submitRequest();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitRequest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final user = _apiService.currentUser;
    final userId = (user != null && user['id'] != null) ? (user['id'] as int) : 1;

    final res = await _apiService.createServiceRequest(
      userId: userId,
      categoryId: _selectedCategory,
      categoryName: _categoryName,
      problem: _selectedProblem,
      description: _descriptionController.text,
      photos: _attachedPhotos,
      address: _addressController.text,
      scheduledAt: _scheduleOption == 'Imediato' ? '' : '$_scheduleOption - $_selectedTime',
      estimatedPrice: 280.00,
    );

    if (mounted) {
      Navigator.pop(context); // fecha loading
      final newId = res['requestId'] as int;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada com sucesso aos profissionais próximos!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrackingScreen(requestId: newId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Solicitação — Etapa ${_currentStep + 1} de 7'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 7.0,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF4F46E5),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentStep == 6 ? 'Enviar Solicitação' : 'Próxima Etapa',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2Problem();
      case 2:
        return _buildStep3Description();
      case 3:
        return _buildStep4Photos();
      case 4:
        return _buildStep5Address();
      case 5:
        return _buildStep6Date();
      case 6:
        return _buildStep7Summary();
      default:
        return const SizedBox.shrink();
    }
  }

  // Etapa 1: Escolher Categoria
  Widget _buildStep1Category() {
    final categories = [
      {'id': 1, 'name': 'Celular', 'icon': Icons.phone_android},
      {'id': 2, 'name': 'Notebook', 'icon': Icons.laptop},
      {'id': 3, 'name': 'Computador', 'icon': Icons.desktop_windows},
      {'id': 4, 'name': 'Videogame', 'icon': Icons.sports_esports},
      {'id': 5, 'name': 'Móveis', 'icon': Icons.chair},
      {'id': 6, 'name': 'TV', 'icon': Icons.tv},
      {'id': 7, 'name': 'Elétrica', 'icon': Icons.flash_on},
      {'id': 8, 'name': 'Hidráulica', 'icon': Icons.water_drop},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 1: Escolha a Categoria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Selecione o tipo de equipamento ou serviço que você necessita.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = _selectedCategory == cat['id'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['id'] as int;
                  _categoryName = cat['name'] as String;
                  _selectedProblem = _problemsByCategory[_categoryName]?.first ?? 'Outro problema';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : const Color(0xFF4F46E5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Etapa 2: Selecionar o Problema
  Widget _buildStep2Problem() {
    final problems = _problemsByCategory[_categoryName] ?? ['Problema técnico geral'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etapa 2: Selecione o Problema ($_categoryName)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Qual o sintoma ou defeito principal que está ocorrendo?', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: problems.length,
          itemBuilder: (context, index) {
            final prob = problems[index];
            final isSelected = _selectedProblem == prob;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2),
              ),
              color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.08) : Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(prob, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5)) : null,
                onTap: () => setState(() => _selectedProblem = prob),
              ),
            );
          },
        ),
      ],
    );
  }

  // Etapa 3: Descrever o Problema
  Widget _buildStep3Description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 3: Descreva os Detalhes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Explique como o defeito ocorreu para que o profissional prepare as ferramentas certas.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Exemplo: O equipamento sofreu uma queda ou contato com água...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Etapa 4: Enviar Fotos
  Widget _buildStep4Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 4: Anexar Fotos do Equipamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Fotos nítidas ajudam o técnico a fornecer uma estimativa mais precisa.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _attachedPhotos.add('foto_equipamento_${_attachedPhotos.length + 1}.jpg');
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Color(0xFF4F46E5), size: 32),
                    SizedBox(height: 4),
                    Text('Adicionar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.image, size: 40, color: Color(0xFF4F46E5)),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _attachedPhotos.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Etapa 5: Selecionar Endereço
  Widget _buildStep5Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 5: Selecionar Endereço de Atendimento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Onde o serviço técnico deverá ser realizado?', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        RadioListTile(
          title: const Text('Utilizar Localização Atual (GPS)'),
          subtitle: const Text('Av. Paulista, 1000 - Bela Vista'),
          value: 'gps',
          groupValue: _addressType,
          onChanged: (val) => setState(() => _addressType = val as String),
        ),
        RadioListTile(
          title: const Text('Digitar Endereço Manualmente'),
          value: 'manual',
          groupValue: _addressType,
          onChanged: (val) => setState(() => _addressType = val as String),
        ),
        if (_addressType == 'manual')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Rua, Número, Bairro, Cidade'),
            ),
          ),
        RadioListTile(
          title: const Text('Endereços Favoritos (Casa / Trabalho)'),
          value: 'favorite',
          groupValue: _addressType,
          onChanged: (val) => setState(() => _addressType = val as String),
        ),
      ],
    );
  }

  // Etapa 6: Escolher Data
  Widget _buildStep6Date() {
    final options = ['Atendimento Imediato', 'Hoje', 'Amanhã', 'Outra Data'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 6: Data e Horário Desejado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Escolha a melhor disponibilidade para receber o profissional.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: options.map((opt) {
            final isSelected = _scheduleOption == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              selectedColor: const Color(0xFF4F46E5),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              onSelected: (val) => setState(() => _scheduleOption = opt),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Horário Preferencial:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: ['09:00', '11:30', '14:30', '17:00'].map((time) {
            final isSelected = _selectedTime == time;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(time),
                selected: isSelected,
                selectedColor: const Color(0xFF4F46E5),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                onSelected: (val) => setState(() => _selectedTime = time),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Etapa 7: Enviar Solicitação (Resumo)
  Widget _buildStep7Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Etapa 7: Confirmar e Enviar Pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Confira o resumo das informações antes do envio automático.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _summaryRow('Categoria', _categoryName),
                const Divider(),
                _summaryRow('Problema', _selectedProblem),
                const Divider(),
                _summaryRow('Descrição', _descriptionController.text),
                const Divider(),
                _summaryRow('Fotos Anexadas', '${_attachedPhotos.length} foto(s)'),
                const Divider(),
                _summaryRow('Endereço', _addressController.text),
                const Divider(),
                _summaryRow('Agendamento', '$_scheduleOption às $_selectedTime'),
                const Divider(),
                _summaryRow('Estimativa Inicial', 'R\$ 280,00', isBold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? const Color(0xFF4F46E5) : Colors.black87,
                fontSize: isBold ? 16 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
