import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int requestId;
  final String proName;

  const ChatScreen({super.key, required this.requestId, required this.proName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await _apiService.getChatMessages(widget.requestId);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final user = _apiService.currentUser;
    final senderId = user?['id'] as int? ?? 1;
    final senderName = user?['name'] as String? ?? 'Usuário';
    final senderRole = user?['role'] as String? ?? 'client';

    try {
      await _apiService.sendChatMessage(
        widget.requestId,
        senderId,
        senderName,
        senderRole,
        text,
      );
      await _loadMessages();
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    }
  }

  void _shareLocation() async {
    final user = _apiService.currentUser;
    final senderId = user?['id'] as int? ?? 1;
    final senderName = user?['name'] as String? ?? 'Usuário';
    final senderRole = user?['role'] as String? ?? 'client';

    const locMsg = '📍 Localização compartilhada: Av. Paulista, 1000 - Portaria Principal';

    try {
      await _apiService.sendChatMessage(
        widget.requestId,
        senderId,
        senderName,
        senderRole,
        locMsg,
      );
      await _loadMessages();
    } catch (e) {
      print('Erro ao compartilhar localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserRole = _apiService.currentUser?['role'] ?? 'client';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.proName.isNotEmpty ? widget.proName : 'Atendimento',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Online agora • Chamado #${widget.requestId}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
          ],
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final msgSenderRole = (msg['sender_role'] ?? 'client').toString();
                      final isMe = msgSenderRole == currentUserRole;
                      final senderName = (msg['sender_name'] ?? (isMe ? 'Você' : 'Atendimento')).toString();
                      final messageContent = (msg['message'] ?? '').toString();

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF4F46E5) : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                messageContent,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.all(12),
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
                IconButton(
                  icon: const Icon(Icons.location_on_outlined, color: Color(0xFF4F46E5)),
                  onPressed: _shareLocation,
                  tooltip: 'Compartilhar Localização',
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF4F46E5)),
                  onPressed: () {},
                  tooltip: 'Enviar Foto',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

