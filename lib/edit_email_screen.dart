import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_provider.dart';

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({super.key});

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _loadCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString('user_email') ?? '';
  }

  Future<void> _saveEmail() async {
    final email = _emailController.text.trim();

    // Validasi email sederhana
    if (!email.contains('@') || !email.contains('.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak valid. Harus mengandung "@" dan ".com"'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);

    // Update juga di Provider agar reflect di UI
    Provider.of<UserProvider>(context, listen: false).updateEmail(email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email berhasil diperbarui!'),
        backgroundColor: Color(0xFF00B4DB),
      ),
    );

    Navigator.pop(context); // kembali ke halaman profil
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Email'),
        backgroundColor: const Color(0xFF203A43),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveEmail,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
