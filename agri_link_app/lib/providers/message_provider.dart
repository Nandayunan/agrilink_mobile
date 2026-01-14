import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageProvider extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api/messages';

  // State
  List<Contact> _contacts = [];
  List<Message> _messages = [];
  List<Message> _inbox = [];
  Message? _selectedMessage;
  Contact? _selectedContact;
  
  bool _isLoading = false;
  String _error = '';
  
  int _unreadCount = 0;

  // Getters
  List<Contact> get contacts => _contacts;
  List<Message> get messages => _messages;
  List<Message> get inbox => _inbox;
  Message? get selectedMessage => _selectedMessage;
  Contact? get selectedContact => _selectedContact;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _unreadCount;

  // ✅ Fetch suppliers dan farmers untuk restoran
  Future<bool> fetchSuppliersAndFarmers(int restaurantId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suppliers-farmers/$restaurantId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _contacts = data.map((json) => Contact.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to fetch suppliers and farmers';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Fetch pesan dengan contact tertentu
  Future<bool> fetchConversation(int restaurantId, int contactId) async {
    _isLoading = true;
    _error = '';
    _selectedContact = _contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => Contact(
        id: contactId,
        name: 'Unknown',
        role: 'admin',
        contactType: 'supplier',
      ),
    );
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversation/$restaurantId/$contactId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _messages = data.map((json) => Message.fromJson(json)).toList();
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to fetch conversation';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Fetch inbox (pesan masuk)
  Future<bool> fetchInbox(int restaurantId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inbox/$restaurantId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _inbox = data.map((json) => Message.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to fetch inbox';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Kirim pesan
  Future<bool> sendMessage({
    required int senderId,
    required int recipientId,
    required String title,
    required String content,
    required String messageType,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'recipientId': recipientId,
          'title': title,
          'content': content,
          'messageType': messageType,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newMessage = Message.fromJson(json);
        _messages.add(newMessage);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to send message';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Tandai pesan sebagai sudah dibaca
  Future<bool> markAsRead(int messageId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mark-as-read/$messageId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Update local state
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final oldMessage = _messages[index];
          _messages[index] = Message(
            id: oldMessage.id,
            senderId: oldMessage.senderId,
            recipientId: oldMessage.recipientId,
            title: oldMessage.title,
            content: oldMessage.content,
            messageType: oldMessage.messageType,
            isRead: true,
            createdAt: oldMessage.createdAt,
            senderName: oldMessage.senderName,
            senderCompany: oldMessage.senderCompany,
            senderRole: oldMessage.senderRole,
            recipientName: oldMessage.recipientName,
            recipientRole: oldMessage.recipientRole,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Dapatkan statistik pesan
  Future<bool> fetchMessageStats(int restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$restaurantId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _unreadCount = data['unread_messages'] ?? 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Tambahkan petani ke favorite
  Future<bool> addFavoriteFarmer(int restaurantId, int farmerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-favorite-farmer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'restaurantId': restaurantId,
          'farmerId': farmerId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Hapus petani dari favorite
  Future<bool> removeFavoriteFarmer(int restaurantId, int farmerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove-favorite-farmer/$restaurantId/$farmerId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Pilih contact untuk percakapan
  void selectContact(Contact contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  // ✅ Clear pesan lama
  void clearMessages() {
    _messages = [];
    _selectedContact = null;
    notifyListeners();
  }
}
