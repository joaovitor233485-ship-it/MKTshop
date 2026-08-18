import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'service_request_wizard_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Celular', 'icon': Icons.phone_android, 'color': const Color(0xFF4F46E5)},
    {'id': 2, 'name': 'Notebook', 'icon': Icons.laptop, 'color': const Color(0xFF0284C7)},
    {'id': 3, 'name': 'Computador', 'icon': Icons.desktop_windows, 'color': const Color(0xFF7C3AED)},
    {'id': 4, 'name': 'Videogame', 'icon': Icons.sports_esports, 'color': const Color(0xFFE11D48)},
    {'id': 5, 'name': 'Móveis', 'icon': Icons.chair, 'color': const Color(0xFFD97706)},
    {'id': 6, 'name': 'TV', 'icon': Icons.tv, 'color': const Color(0xFF059669)},
    {'id': 7, 'name': 'Elétrica', 'icon': Icons.flash_on, 'color': const Color(0xFFCA8A04)},
    {'id': 8, 'name': 'Hidráulica', 'icon': Icons.water_drop, 'color': const Color(0xFF2563EB)},
  ];

  @override
  Widget build(BuildContext context) {
    final userName = _apiService.currentUser?['name'] ?? 'Cliente';

    return Scaffold(
      body: _buildCurrentTab(userName),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey[600],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Meus Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(String userName) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard(userName);
      case 1:
        return const HistoryScreen();
      case 2:
        return _buildProfileTab(userName);
      default:
        return _buildHomeDashboard(userName);
    }
  }

  // Aba 1: Dashboard Inicial do Cliente
  Widget _buildHomeDashboard(String userName) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Superior com Gradiente
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bem-vindo de volta,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Campo de Busca
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'O que precisa consertar hoje?',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF4F46E5)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Banner Promocional
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(8)),
                          child: const Text('OFERTA ESPECIAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        const Text('Assistência Técnica Domiciliar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1B4B))),
                        const Text('Técnicos qualificados com garantia e preço justo.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_user, size: 48, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título de Categorias
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Selecione o Serviço Desejado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
          ),
          const SizedBox(height: 12),

          // Grid de Categorias com Ícones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceRequestWizardScreen(
                          selectedCategoryId: cat['id'] as int,
                          selectedCategoryName: cat['name'] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1B4B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Atalho Rápido para Histórico de Pedidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.history_toggle_off, color: Color(0xFF4F46E5)),
                title: const Text('Acompanhar Meus Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Veja o status e localização dos técnicos em tempo real.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _currentIndex = 1),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Aba 3: Perfil do Cliente
  Widget _buildProfileTab(String userName) {
    final user = _apiService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user?['email'] ?? 'cliente@shopmkt.com', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Color(0xFF4F46E5)),
            title: const Text('Endereços Salvos'),
            subtitle: Text(user?['address'] ?? 'Av. Paulista, 1000 - SP'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF4F46E5)),
            title: const Text('Suporte e Ajuda'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair do Aplicativo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}


