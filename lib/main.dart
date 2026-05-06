import 'package:flutter/material.dart';

void main() {
  runApp(const QnoteApp());
}

class QnoteApp extends StatelessWidget {
  const QnoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "Qnote",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}