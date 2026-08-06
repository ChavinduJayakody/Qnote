import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  static const String _storageKey = 'qnote_notes';
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  List<Note> get pinnedNotes =>
      _notes.where((n) => n.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Note> get unpinnedNotes =>
      _notes.where((n) => !n.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Note> get favoriteNotes =>
      _notes.where((n) => n.isFavorite).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Note> get sortedNotes => [...pinnedNotes, ...unpinnedNotes];

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _notes = jsonList.map((json) => Note.fromJson(json)).toList();
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      note.updatedAt = DateTime.now();
      _notes[index] = note;
      await _saveNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _notes[index].updatedAt = DateTime.now();
      await _saveNotes();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isFavorite = !_notes[index].isFavorite;
      _notes[index].updatedAt = DateTime.now();
      await _saveNotes();
    }
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return sortedNotes;
    final lowerQuery = query.toLowerCase();
    return sortedNotes
        .where((n) =>
            n.title.toLowerCase().contains(lowerQuery) ||
            n.content.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<Note> filterByCategory(NoteCategory? category) {
    if (category == null) return sortedNotes;
    return sortedNotes.where((n) => n.category == category).toList();
  }

  int get totalNotes => _notes.length;
  int get totalPinned => _notes.where((n) => n.isPinned).length;
  int get totalFavorites => _notes.where((n) => n.isFavorite).length;
}
