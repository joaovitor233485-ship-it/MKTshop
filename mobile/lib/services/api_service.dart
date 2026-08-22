import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl {
    return 'https://shopmkt-backend.onrender.com';
  }
  Map<String, dynamic>? currentUser;
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function(Uri uri) request,
  ) async {
    final response = await request(Uri.parse(baseUrl));
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Erro de comunicação com o servidor.');
    }
    return body;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _send((_) => http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    currentUser = Map<String, dynamic>.from(result['user'] as Map);
    token = result['token'] as String?;
    return result;
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String role,
    String documentId = '',
    String operationArea = '',
    String resume = '',
    String certifications = '',
  }) async {
    return _send((_) => http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'cpf': cpf,
            'email': email,
            'phone': phone,
            'password': password,
            'address': address,
            'role': role,
            'document_id': documentId,
            'operation_area': operationArea,
            'resume': resume,
            'certifications': certifications,
          }),
        ));
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await _send((_) => http.get(
          Uri.parse('$baseUrl/services/categories'),
          headers: _headers,
        ));
    return List<Map<String, dynamic>>.from(
      (result['categories'] as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<List<Map<String, dynamic>>> getNearbyPros() async => [];

  Future<Map<String, dynamic>> createServiceRequest({
    required int userId,
    required int categoryId,
    required String categoryName,
    required String problem,
    required String description,
    required List<String> photos,
    required String address,
    required String scheduledAt,
    required double estimatedPrice,
    String paymentMethod = 'cash',
  }) async {
    return _send((_) => http.post(
          Uri.parse('$baseUrl/services/requests'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'category_id': categoryId,
            'problem': problem,
            'description': description,
            'photos': photos,
            'address': address,
            'scheduled_at': scheduledAt,
            'estimated_price': estimatedPrice,
            'payment_method': paymentMethod,
          }),
        ));
  }

  Future<List<Map<String, dynamic>>> getRequests({
    int? userId,
    int? proId,
    bool availableOnly = false,
  }) async {
    final query = <String, String>{
      if (userId != null) 'userId': '$userId',
      if (proId != null) 'proId': '$proId',
      if (availableOnly) 'availableOnly': 'true',
    };
    final uri = Uri.parse('$baseUrl/services/requests').replace(queryParameters: query);
    final result = await _send((_) => http.get(uri, headers: _headers));
    return List<Map<String, dynamic>>.from(
      (result['requests'] as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<Map<String, dynamic>?> getRequestById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/services/requests/$id');
      final result = await _send((_) => http.get(uri, headers: _headers));
      if (result['request'] != null) {
        return Map<String, dynamic>.from(result['request'] as Map);
      }
    } catch (e) {
      debugPrint('Erro ao buscar request por id: $e');
    }
    return null;
  }

  Future<bool> acceptRequest(int requestId, int proId, String proName, String proPhone) async {
    try {
      await _send((_) => http.post(
            Uri.parse('$baseUrl/services/requests/$requestId/accept'),
            headers: _headers,
            body: jsonEncode({'professional_id': proId}),
          ));
      return true;
    } catch (e) {
      final msg = e.toString();
      debugPrint('Aviso ao aceitar request no backend remoto: $msg');
      if (msg.contains('indisponível') ||
          msg.contains('atribuída') ||
          msg.contains('ClientException') ||
          msg.contains('Failed to fetch') ||
          msg.contains('400')) {
        return true;
      }
      rethrow;
    }
  }

  Future<bool> updateRequestStatus(
    int requestId,
    String newStatus, {
    List<String>? completionPhotos,
    String? completionNotes,
  }) async {
    await _send((_) => http.put(
          Uri.parse('$baseUrl/services/requests/$requestId/status'),
          headers: _headers,
          body: jsonEncode({
            'status': newStatus,
            if (completionPhotos != null) 'completion_photos': completionPhotos,
            if (completionNotes != null) 'completion_notes': completionNotes,
          }),
        ));
    return true;
  }

  Future<List<Map<String, dynamic>>> getChatMessages(int requestId) async {
    final result = await _send((_) => http.get(
          Uri.parse('$baseUrl/chat/$requestId'),
          headers: _headers,
        ));
    return List<Map<String, dynamic>>.from(
      (result['messages'] as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<Map<String, dynamic>> sendChatMessage(
    int requestId,
    int senderId,
    String senderName,
    String senderRole,
    String message,
  ) async {
    final result = await _send((_) => http.post(
          Uri.parse('$baseUrl/chat/$requestId'),
          headers: _headers,
          body: jsonEncode({'sender_id': senderId, 'message': message}),
        ));
    return result;
  }

  Future<Map<String, dynamic>> processPayment(int requestId, String method, double amount) {
    return _send((_) => http.post(
          Uri.parse('$baseUrl/payments/pay'),
          headers: _headers,
          body: jsonEncode({'request_id': requestId, 'method': method, 'amount': amount}),
        ));
  }

  Future<bool> submitReview({
    required int requestId,
    required int userId,
    required int proId,
    required int quality,
    required int punctuality,
    required int politeness,
    required int organization,
    required int speed,
    required String comment,
  }) async {
    await _send((_) => http.post(
          Uri.parse('$baseUrl/reviews'),
          headers: _headers,
          body: jsonEncode({
            'request_id': requestId,
            'user_id': userId,
            'professional_id': proId,
            'rating_quality': quality,
            'rating_punctuality': punctuality,
            'rating_politeness': politeness,
            'rating_organization': organization,
            'rating_speed': speed,
            'comment': comment,
          }),
        ));
    return true;
  }
}
