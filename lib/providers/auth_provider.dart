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

  // ================= URL SETTING =================
  final String _baseUrl = 'http://127.0.0.1:5000';

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

// ================= UPDATE DATA PROFIL KE FLASK =================
  Future<bool> updateProfileApi({
    required String username,
    required String email,
  }) async {
    if (_user == null) return false;

    try {
      final String idUser = _user!['id'].toString();
      
      // Jika Anda testing menggunakan Emulator Android, ganti 127.0.0.1 menjadi 10.0.2.2
      var uri = Uri.parse('$_baseUrl/api/user/update');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id': idUser,
          'username': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      
      debugPrint("FLASK UPDATE FAILED: ${response.statusCode} - ${response.body}");
      return false;
    } catch (e) {
      debugPrint("FLASK UPDATE ERROR: $e");
      return false;
    }
  }

  // ================= UPLOAD FOTO PROFIL =================
  Future<bool> uploadProfilePicture(XFile pickedFile) async {
    if (_user == null) return false;

    try {
      var uri = Uri.parse('$_baseUrl/api/update_foto');
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

  // ================= UBAH PASSWORD KE FLASK =================
  Future<Map<String, dynamic>> changePasswordApi({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_user == null) return {'success': false, 'message': 'Sesi pengguna tidak ditemukan'};

    try {
      final String idUser = _user!['id'].toString();
      var uri = Uri.parse('$_baseUrl/api/user/change-password');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id': idUser,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password berhasil diperbarui'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Gagal memperbarui password'};
      }
    } catch (e) {
      debugPrint("CHANGE PASSWORD ERROR: $e");
      return {'success': false, 'message': 'Terjadi kesalahan jaringan atau server'};
    }
  }

  // ================= UPDATE NOTIFIKASI KE FLASK =================
  Future<bool> updateNotificationApi({
    required bool pushNotif,
    required bool emailNotif,
    required bool promoNotif,
  }) async {
    if (_user == null) return false;

    try {
      final String idUser = _user!['id'].toString();
      var uri = Uri.parse('$_baseUrl/api/user/notification');

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id': idUser,
          'push_notifications': pushNotif ? 1 : 0,  // Diubah ke int (1/0) untuk MySQL BIT/TINYINT
          'email_notifications': emailNotif ? 1 : 0,
          'promo_notifications': promoNotif ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        // Update local state agar sinkron di memori aplikasi
        final updatedUser = Map<String, dynamic>.from(_user!);
        updatedUser['push_notifications'] = pushNotif ? 1 : 0;
        updatedUser['email_notifications'] = emailNotif ? 1 : 0;
        updatedUser['promo_notifications'] = promoNotif ? 1 : 0;
        await updateUser(updatedUser);
        return true;
      }
      
      debugPrint("NOTIFICATION API FAILED: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("NOTIFICATION API ERROR: $e");
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