import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'film_model.dart';
import 'db_helper.dart';

class FilmFormScreen extends StatefulWidget {
  final Film? film;
  final Function(Film) onSave;

  const FilmFormScreen({super.key, this.film, required this.onSave});

  @override
  State<FilmFormScreen> createState() => _FilmFormScreenState();
}

class _FilmFormScreenState extends State<FilmFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _genre = 'Horror';
  File? _posterImage;
  bool _isSaving = false;

  final List<String> _genres = [
    'Horror',
    'Action',
    'Romance',
    'Fantasy',
    'Comedy',
    'Drama',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.film != null) {
      _titleController.text = widget.film!.title;
      _descController.text = widget.film!.description;
      _genre = widget.film!.genre;
      if (widget.film!.posterPath.isNotEmpty) {
        _posterImage = File(widget.film!.posterPath);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _posterImage = File(pickedFile.path);
      });
    }
    Navigator.of(context).pop(); // Tutup dialog
  }

  void _showPickImageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyanAccent),
                title: const Text(
                  "Ambil dari Kamera",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  "Pilih dari Galeri",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _posterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field dan poster harus diisi!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newFilm = Film(
      id: widget.film?.id ?? Random().nextDouble().toString(),
      title: _titleController.text,
      description: _descController.text,
      genre: _genre,
      posterPath: _posterImage!.path,
    );

    final db = DatabaseHelper.instance;

    if (widget.film == null) {
      await db.insertFilm(newFilm);
    } else {
      await db.updateFilm(newFilm);
    }

    widget.onSave(newFilm);

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.pop(context, newFilm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.film == null ? 'Tambah Film' : 'Edit Film',
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_titleController, 'Judul Film'),
                const SizedBox(height: 16),
                _buildTextField(_descController, 'Deskripsi'),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _genre,
                  dropdownColor: const Color(0xFF203A43),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Genre'),
                  items:
                      _genres
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _genre = val!),
                ),
                const SizedBox(height: 16),
                _posterImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _posterImage!,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                    : const Text(
                      'Belum ada poster',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _showPickImageDialog,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Tambahkan Poster'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                            : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.cyanAccent),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.cyanAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
