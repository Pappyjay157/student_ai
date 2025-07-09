import 'screens/home.dart';
import 'screens/upload.dart';
import 'screens/editor.dart';
import 'screens/chat_bot.dart';
import 'screens/final_content.dart';
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
        '/chat': (c) => const ChatBotScreen(),
        '/upload': (c) => const UploadNotesScreen(),
        '/editor': (c) => const DraftEditorScreen(),
        '/preferences': (c) => const WritingPreferencesScreen(),
        '/final': (c) => const FinalContentScreen(),
      },
    );
  }
}
