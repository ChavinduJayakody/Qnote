import 'dart:convert';

enum NoteCategory {
  general,
  work,
  personal,
  ideas,
  todo,
  important,
}

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.general:
        return 'General';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.ideas:
        return 'Ideas';
      case NoteCategory.todo:
        return 'To-Do';
      case NoteCategory.important:
        return 'Important';
    }
  }

  String get emoji {
    switch (this) {
      case NoteCategory.general:
        return '📝';
      case NoteCategory.work:
        return '💼';
      case NoteCategory.personal:
        return '🏠';
      case NoteCategory.ideas:
        return '💡';
      case NoteCategory.todo:
        return '✅';
      case NoteCategory.important:
        return '⭐';
    }
  }
}

class Note {
  final String id;
  String title;
  String content;
  NoteCategory category;
  bool isPinned;
  bool isFavorite;
  int colorIndex;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.category = NoteCategory.general,
    this.isPinned = false,
    this.isFavorite = false,
    this.colorIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.index,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: NoteCategory.values[json['category'] ?? 0],
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      colorIndex: json['colorIndex'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Note.fromJsonString(String jsonString) {
    return Note.fromJson(jsonDecode(jsonString));
  }
}
