import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteService noteService;

  const AddNoteScreen({super.key, required this.noteService});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void saveNote() {
    final note = Note(
      id: const Uuid().v4(),
      title: titleController.text,
      content: contentController.text,
    );

    widget.noteService.addNote(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Content"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNote,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}