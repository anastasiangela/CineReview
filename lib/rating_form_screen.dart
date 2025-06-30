import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'film_model.dart';

class RatingFormScreen extends StatefulWidget {
  final String filmId;

  const RatingFormScreen({super.key, required this.filmId});

  @override
  State<RatingFormScreen> createState() => _RatingFormScreenState();
}

class _RatingFormScreenState extends State<RatingFormScreen> {
  final db = DatabaseHelper.instance;
  double _rating = 3.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beri Rating Film'),
        backgroundColor: Colors.cyan,
      ),
      backgroundColor: const Color(0xFF0F2027),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Pilih jumlah bintang',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _rating,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: _rating.toStringAsFixed(1),
              activeColor: Colors.cyan,
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            Text(
              '${_rating.toStringAsFixed(1)} ${_rating > 0 ? '★' : ''}',
              style: const TextStyle(color: Colors.yellowAccent, fontSize: 24),
            ),
            const SizedBox(height: 30),
            _isSubmitting
                ? const CircularProgressIndicator(color: Colors.cyan)
                : ElevatedButton.icon(
                  onPressed: _submitRating,
                  icon: const Icon(Icons.check),
                  label: const Text('Simpan Rating'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    final film = await db.getFilmById(widget.filmId);
    if (film != null) {
      double oldRating = film.rating;
      double newRating = oldRating > 0 ? (oldRating + _rating) / 2.0 : _rating;

      final updatedFilm = Film(
        id: film.id,
        title: film.title,
        genre: film.genre,
        description: film.description,
        posterPath: film.posterPath, // ✅ perbaikan di sini
        rating: double.parse(newRating.toStringAsFixed(1)),
      );

      await db.updateFilm(updatedFilm);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rating berhasil disimpan!"),
            backgroundColor: Colors.cyan,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}
