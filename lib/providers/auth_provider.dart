import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  // ================= SECURE STORAGE =================
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ================= STATE =================
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = true;

  // ================= GETTERS =================
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  bool get isLogin => _token != null && _user != null;

  int get userId => _user?['id'] ?? 0;

  String get nama => _user?['username'] ?? '';

  String get username => _user?['username'] ?? '';

  String get email => _user?['email'] ?? '';

  String get fotoProfil => _user?['foto_profil'] ?? '';

  bool get isAdmin => _user?['role'] == 'admin';

  bool get hasToken => _token != null && _token!.isNotEmpty;

  // ================= CONSTRUCTOR =================
  AuthProvider() {
    loadSession();
  }

  // ================= LOGIN =================
  Future<void> setLogin({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    _token = token;
    _user = userData;

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'user', value: jsonEncode(userData));

    notifyListeners();
  }

  // ================= LOAD SESSION =================
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _storage.read(key: 'token');
      final savedUser = await _storage.read(key: 'user');

      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _user = jsonDecode(savedUser);
      }
    } catch (e) {
      _token = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= UPDATE USER (WAJIB HARD REFRESH STATE) =================
  Future<void> updateUser(Map<String, dynamic> newUser) async {
    _user = Map<String, dynamic>.from(newUser); // 🔥 HARD COPY biar UI detect perubahan

    await _storage.write(
      key: 'user',
      value: jsonEncode(_user),
    );

    notifyListeners();
  }

  // ================= UPLOAD FOTO PROFIL =================
  Future<bool> uploadProfilePicture(XFile pickedFile) async {
    if (_user == null) return false;

    try {
      var uri = Uri.parse('http://127.0.0.1:5000/api/update_foto');
      var request = http.MultipartRequest('POST', uri);

      request.fields['id'] = _user!['id'].toString();

      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto_profil',
            bytes,
            filename: pickedFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_profil',
            pickedFile.path,
          ),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['foto_profil'] != null) {
          // 🔥 FORCE UPDATE USER (BIAR UI LANGSUNG GANTI)
          final updatedUser = Map<String, dynamic>.from(_user!);
          updatedUser['foto_profil'] = data['foto_profil'];

          await updateUser(updatedUser);

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _user = null;
    _token = null;

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');

    notifyListeners();
  }
}