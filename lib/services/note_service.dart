import '../models/note.dart';

class NoteService {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
  }
}