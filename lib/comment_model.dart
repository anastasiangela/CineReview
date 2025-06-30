class Comment {
  final int? id;
  final String filmId;
  final String content;
  final String author;
  final DateTime createdAt;
  final int likes;
  final int? parentId; // ✅ Tambahan untuk komentar balasan

  Comment({
    this.id,
    required this.filmId,
    required this.content,
    required this.author,
    DateTime? createdAt,
    this.likes = 0,
    this.parentId, // ✅ Tambahan di konstruktor
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ Mengubah objek Comment menjadi map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filmId': filmId,
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(), // Disimpan sebagai string ISO
      'likes': likes,
      'parentId': parentId, // ✅ Simpan parentId
    };
  }

  // ✅ Membuat objek Comment dari data map SQLite
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      filmId: map['filmId'],
      content: map['content'],
      author: map['author'],
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      likes: map['likes'] ?? 0,
      parentId: map['parentId'], // ✅ Ambil parentId dari DB
    );
  }
}
