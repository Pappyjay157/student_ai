import 'screens/home.dart';
import 'screens/upload.dart';
import 'screens/editor.dart';
import 'package:flutter/material.dart';
import 'screens/writing_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Student Assistant',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => const HomeScreen(),
        '/upload': (c) => const UploadNotesScreen(),
        '/draft': (c) => const DraftEditorScreen(),
        '/preferences': (c) => const WritingPreferencesScreen(),
      },
    );
  }
}
