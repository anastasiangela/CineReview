import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  // Data default jika tidak ditemukan di SharedPreferences
  String _name = 'Admin CineReview';
  String _email = 'admin@cinereview.com';

  // Getter
  String get name => _name;
  String get email => _email;

  // Memuat data user dari SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? 'Admin CineReview';
    _email = prefs.getString('user_email') ?? 'admin@cinereview.com';
    notifyListeners();
  }

  // Memperbarui nama user
  Future<void> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    _name = newName;
    notifyListeners();
  }

  // Memperbarui email user
  Future<void> updateEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', newEmail);
    _email = newEmail;
    notifyListeners();
  }
}
