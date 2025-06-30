import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_flutter_uaspemob/film%20_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'film_model.dart';
import 'db_helper.dart'; // ✅ Tambahkan import ini
import 'comment_screen.dart'; // Import comments screen
import 'rating_form_screen.dart'; // Import rating form screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Film> _films = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final db = DatabaseHelper.instance;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _loadFilms(); // ✅ Load data dari database saat pertama
  }

  Future<void> _loadFilms() async {
    final data = await db.getAllFilms(); // Mengambil data film dari database
    setState(() {
      _films = data;
    });
  }

  void _addFilm(Film film) async {
    await db.insertFilm(film);
    _loadFilms(); // Refresh list
  }

  void _editFilm(String id, Film updatedFilm) async {
    await db.updateFilm(updatedFilm);
    _loadFilms(); // Refresh list
  }

  void _deleteFilm(String id) async {
    await db.deleteFilm(id);
    _loadFilms(); // Refresh list
  }

  Future<void> _openForm({Film? film}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FilmFormScreen(
              film: film,
              onSave: (Film updated) {
                if (film == null) {
                  _addFilm(updated);
                } else {
                  _editFilm(film.id, updated);
                }
              },
            ),
      ),
    );

    // Jika result tidak null, maka refresh daftar film
    if (result != null && result is Film) {
      _loadFilms();
    }
  }

  List<Film> get _filteredFilms {
    if (_searchQuery.isNotEmpty) {
      return _films
          .where(
            (film) =>
                film.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_selectedGenre != null && _selectedGenre != "Semua") {
      return _films.where((film) => film.genre == _selectedGenre).toList();
    }
    return _films;
  }

  void _showFilmDetails(Film film) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C2D35),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Image.file(
                      File(
                        film.posterPath,
                      ), // Ganti dengan File untuk posterPath
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  film.title,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Genre: ${film.genre}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  film.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RatingFormScreen(filmId: film.id),
                          ),
                        ).then((_) {
                          _loadFilms(); // ⏪ Refresh data setelah kembali dari RatingFormScreen
                          Navigator.pop(context); // ⏪ Tutup detail dialog juga
                        });
                      },
                      child: const Text(
                        '⭐',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CommentsScreen(filmId: film.id),
                          ),
                        );
                      },
                      child: const Text(
                        '💬',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _openForm(film: film);
                      },
                      child: const Text(
                        '📝',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteFilm(film.id);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '🗑',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'CineReview',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    color: const Color(0xFF1C2D35),
                    onSelected: (value) async {
                      if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 'logout') {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1C2D35),
                                title: const Text(
                                  'Konfirmasi Logout',
                                  style: TextStyle(color: Colors.cyanAccent),
                                ),
                                content: const Text(
                                  'Apakah kamu yakin ingin keluar dari akun ini?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldLogout == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('is_logged_in', false);
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: Text(
                              'Profil',
                              style: TextStyle(color: Colors.cyanAccent),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari film bioskop...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GenreChip(
                        label: "Semua",
                        selected:
                            _selectedGenre == null || _selectedGenre == "Semua",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Action",
                        selected: _selectedGenre == "Action",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Drama",
                        selected: _selectedGenre == "Drama",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Romance",
                        selected: _selectedGenre == "Romance",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Comedy",
                        selected: _selectedGenre == "Comedy",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Horror",
                        selected: _selectedGenre == "Horror",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                      GenreChip(
                        label: "Fantasy",
                        selected: _selectedGenre == "Fantasy",
                        onGenreSelected: (genre) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    _filteredFilms.isEmpty
                        ? const Center(
                          child: Text(
                            'Tidak ada film ditemukan',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _filteredFilms.length,
                          itemBuilder: (context, index) {
                            final film = _filteredFilms[index];
                            return GestureDetector(
                              onTap: () => _showFilmDetails(film),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.file(
                                        File(
                                          film.posterPath,
                                        ), // Ganti dengan File untuk posterPath
                                        width: double.infinity,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        film.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            film.rating.toString(),
                                            style: const TextStyle(
                                              color: Colors.yellowAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              film.genre.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 45,
        height: 45,
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.add, size: 20),
        ),
      ),
    );
  }

  void showSearchBar() {
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
}

class GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function(String?) onGenreSelected;

  const GenreChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        backgroundColor: Colors.blueGrey.shade700,
        selectedColor: Colors.cyan,
        labelStyle: const TextStyle(color: Colors.white),
        onSelected: (isSelected) {
          onGenreSelected(isSelected ? label : null);
        },
      ),
    );
  }
}
