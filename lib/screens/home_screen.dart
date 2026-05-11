import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'add_note_screen.dart';
import '../widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  final NoteService noteService;

  const HomeScreen({super.key, required this.noteService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Note> notes = widget.noteService.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Qnote"),
        centerTitle: true,
      ),
      body: notes.isEmpty
          ? const Center(child: Text("No notes yet"))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(note: note);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddNoteScreen(noteService: widget.noteService),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}