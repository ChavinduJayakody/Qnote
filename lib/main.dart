import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/note_service.dart';

void main() {
  runApp(const QnoteApp());
}

class QnoteApp extends StatelessWidget {
  const QnoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final noteService = NoteService(); // ✅ create instance

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(noteService: noteService), // ✅ PASS IT HERE
    );
  }
}