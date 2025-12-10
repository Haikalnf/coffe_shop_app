import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<void> login(String email, String password) async {
    
    await Future.delayed(const Duration(seconds: 1));

    
    final emailMasuk = email.trim().toLowerCase();
    final passMasuk = password.trim();

    
    if (emailMasuk.isEmpty || passMasuk.length < 6) {
      throw Exception("Email atau Password tidak valid (min 6 karakter)");
    }

    

    
    if (emailMasuk == 'haikal@gmail.com') {
      
      if (passMasuk == 'nalus5678') {
        
        _currentUser = UserModel(
          id: 'admin_id',
          name: 'Haikal (Admin)',
          email: emailMasuk,
          password: passMasuk,
          role: 'admin', 
        );
      } else {
        
        throw Exception("Password Khusus Admin Salah!");
      }
    } else {
      
    
      String name = email.split('@')[0];

      _currentUser = UserModel(
        id: 'user_id_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: emailMasuk,
        password: passMasuk,
        role: 'user', 
      );
    }
    

    _isLoggedIn = true;
    notifyListeners();
  }

  
  Future<void> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
