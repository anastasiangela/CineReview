import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'user_provider.dart'; // tambahkan ini

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImagePath();
  }

  Future<void> _saveImageToLocalDirectory(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imagePath);
    final localImage = await File(
      imagePath,
    ).copy('${directory.path}/$fileName');
    await _saveImagePath(localImage.path);
    setState(() {
      _imageFile = localImage;
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _imageFile = File(savedPath);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyan),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    await _saveImageToLocalDirectory(picked.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.cyan),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    await _saveImageToLocalDirectory(picked.path);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.redAccent),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmEdit(String field) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF203A43),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Konfirmasi',
              style: TextStyle(color: Colors.cyanAccent),
            ),
            content: Text(
              'Apakah kamu yakin ingin mengubah $field?',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.white12,
                highlightColor: Colors.white10,
                onTap: () => Navigator.pop(context, false),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Batal', style: TextStyle(color: Colors.white70)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Ya, Ubah'),
              ),
            ],
          ),
    );

    if (result == true) {
      if (field == 'Nama') {
        _navigateToNameEdit();
      } else if (field == 'Email') {
        _navigateToEmailEdit();
      }
    }
  }

  void _navigateToNameEdit() {
    Navigator.pushNamed(context, '/edit-name');
  }

  void _navigateToEmailEdit() {
    Navigator.pushNamed(context, '/edit-email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final name = userProvider.name;
              final email = userProvider.email;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.cyanAccent,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Profil Pengguna',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[400],
                    backgroundImage:
                        _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent),
                      ),
                      child: const Text(
                        'Edit Foto Profil',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(
                    color: Colors.white24,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    onTap: () => _confirmEdit('Nama'),
                    leading: const Icon(Icons.person, color: Colors.cyanAccent),
                    title: const Text(
                      'Nama',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                  ListTile(
                    onTap: () => _confirmEdit('Email'),
                    leading: const Icon(Icons.email, color: Colors.cyanAccent),
                    title: const Text(
                      'Email',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
