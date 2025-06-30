class Film {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String
  posterPath; // ✅ Ubah dari posterUrl ke posterPath (lokasi file lokal)
  final double rating; // ✅ Rating tetap

  Film({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.posterPath,
    this.rating = 0.0,
  });

  // ✅ Simpan ke database (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'posterPath': posterPath, // ✅ simpan path gambar lokal
      'rating': rating,
    };
  }

  // ✅ Ambil dari database
  factory Film.fromMap(Map<String, dynamic> map) {
    return Film(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      genre: map['genre'],
      posterPath: map['posterPath'], // ✅ ambil path lokal
      rating: map['rating'] != null ? map['rating'].toDouble() : 0.0,
    );
  }

  @override
  String toString() {
    return 'Film{id: $id, title: $title, genre: $genre, rating: $rating}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Film &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          genre == other.genre &&
          rating == other.rating &&
          posterPath == other.posterPath;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      genre.hashCode ^
      rating.hashCode ^
      posterPath.hashCode;
}
