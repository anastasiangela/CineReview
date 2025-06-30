import 'package:flutter/material.dart';
import 'comment_model.dart';

class CommentForm extends StatefulWidget {
  final Comment? comment; // Untuk edit
  final Comment? parentComment; // Untuk reply
  final Function(Comment) onSubmit;
  final String filmId;

  const CommentForm({
    super.key,
    this.comment,
    this.parentComment,
    required this.onSubmit,
    required this.filmId,
  });

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      _authorController.text = widget.comment!.author;
      _contentController.text = widget.comment!.content;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newComment = Comment(
        id: widget.comment?.id,
        filmId: widget.filmId,
        author: _authorController.text.trim(),
        content: _contentController.text.trim(),
        parentId: widget.parentComment?.id, // ✅ Set parentId jika ini reply
      );
      widget.onSubmit(newComment);
      Navigator.pop(context); // Tutup form setelah submit
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2D35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.comment == null
            ? widget.parentComment == null
                ? 'Tambah Komentar'
                : 'Balas Komentar'
            : 'Edit Komentar',
        style: const TextStyle(color: Colors.cyanAccent),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _authorController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: const TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Komentar',
                  labelStyle: const TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Komentar tidak boleh kosong'
                            : null,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
