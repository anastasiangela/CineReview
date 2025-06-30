import 'package:flutter/material.dart';
import 'comment_model.dart';
import 'db_helper.dart';
import 'comment_form_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final String filmId;

  const CommentsScreen({super.key, required this.filmId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final db = DatabaseHelper.instance;
  List<Comment> _comments = [];
  String _sortOrder = 'latest';
  Set<int> likedComments = {}; // Set to track liked comments

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final data = await db.getCommentsByFilmId(widget.filmId);
    setState(() {
      _comments = data;
      _sortComments();
    });
  }

  void _sortComments() {
    switch (_sortOrder) {
      case 'latest':
        _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'hottest':
        _comments.sort((a, b) => b.likes.compareTo(a.likes));
        break;
    }
  }

  Future<List<Comment>> _loadReplies(int parentId) async {
    return await db.getReplies(parentId);
  }

  void _addComment(Comment comment) async {
    await db.insertComment(comment);
    _loadComments();
  }

  void _updateComment(Comment comment) async {
    await db.updateComment(comment);
    _loadComments();
  }

  void _deleteComment(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1C2D35),
            title: const Text(
              'Hapus Komentar',
              style: TextStyle(color: Colors.cyanAccent),
            ),
            content: const Text(
              'Apakah kamu yakin ingin menghapus komentar ini?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await db.deleteComment(id);
      _loadComments();
    }
  }

  void _likeComment(Comment comment) async {
    if (!likedComments.contains(comment.id!)) {
      final updatedComment = Comment(
        id: comment.id,
        filmId: comment.filmId,
        content: comment.content,
        author: comment.author,
        createdAt: comment.createdAt,
        likes: comment.likes + 1,
        parentId: comment.parentId,
      );
      await db.updateComment(updatedComment);
      setState(() {
        likedComments.add(comment.id!); // Add to liked comments
      });
      _loadComments();
    }
  }

  void _unlikeComment(Comment comment) async {
    if (likedComments.contains(comment.id!)) {
      final updatedComment = Comment(
        id: comment.id,
        filmId: comment.filmId,
        content: comment.content,
        author: comment.author,
        createdAt: comment.createdAt,
        likes: comment.likes - 1,
        parentId: comment.parentId,
      );
      await db.updateComment(updatedComment);
      setState(() {
        likedComments.remove(comment.id!); // Remove from liked comments
      });
      _loadComments();
    }
  }

  void _openCommentForm({Comment? comment}) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: const Color(0xFF1C2D35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: CommentForm(
                comment: comment,
                filmId: widget.filmId,
                onSubmit: (Comment newComment) {
                  if (comment == null) {
                    _addComment(newComment);
                  } else {
                    _updateComment(newComment);
                  }
                },
              ),
            ),
          ),
    );
  }

  void _openReplyForm(Comment parentComment) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: const Color(0xFF1C2D35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: CommentForm(
                parentComment: parentComment,
                filmId: widget.filmId,
                onSubmit: (Comment replyComment) {
                  final updatedReply = Comment(
                    id: replyComment.id,
                    filmId: replyComment.filmId,
                    content: replyComment.content,
                    author: replyComment.author,
                    createdAt: replyComment.createdAt,
                    likes: replyComment.likes,
                    parentId: parentComment.id,
                  );
                  _addComment(updatedReply);
                },
              ),
            ),
          ),
    );
  }

  Widget _buildSortChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 8,
        children:
            ['latest', 'oldest', 'hottest'].map((sort) {
              final isSelected = _sortOrder == sort;
              return ChoiceChip(
                label: Text(
                  sort == 'latest'
                      ? 'Terbaru'
                      : sort == 'oldest'
                      ? 'Terlama'
                      : 'Terpopuler',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.cyan,
                backgroundColor: Colors.white10,
                onSelected: (_) {
                  setState(() {
                    _sortOrder = sort;
                    _sortComments(); // Call sorting method after changing sort order
                  });
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return FutureBuilder<List<Comment>>(
      future: _loadReplies(comment.id!),
      builder: (context, snapshot) {
        final replies = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2D35),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.cyan,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.author,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                timeago.format(comment.createdAt),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _deleteComment(comment.id!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Adjust the text widget to wrap and fit the bubble
                    Text(
                      comment.content,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 3, // Limit the number of lines
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for overflow
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color:
                                likedComments.contains(comment.id!)
                                    ? Colors.redAccent
                                    : Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (likedComments.contains(comment.id!)) {
                              _unlikeComment(comment);
                            } else {
                              _likeComment(comment);
                            }
                          },
                        ),
                        Text(
                          comment.likes.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.reply,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                          onPressed: () => _openReplyForm(comment),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 4),
                child: Column(
                  children: replies.map(_buildCommentTile).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar Film'),
        backgroundColor: Colors.cyan,
      ),
      backgroundColor: const Color(0xFF0F2027),
      body:
          _comments.isEmpty
              ? const Center(
                child: Text(
                  'Belum ada komentar',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSortChips(),
                  Expanded(
                    child: ListView(
                      children: _comments.map(_buildCommentTile).toList(),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCommentForm(),
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }
}
