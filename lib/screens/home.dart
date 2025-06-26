import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student AI Assistant')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Notes'),
            onPressed: () => Navigator.pushNamed(c, '/upload'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Start New Draft'),
            onPressed: () => Navigator.pushNamed(c, '/draft'),
          ),
        ]),
      ),
    );
  }
}
