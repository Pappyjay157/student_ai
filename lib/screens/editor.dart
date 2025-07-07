import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DraftEditorScreen extends StatefulWidget {
  const DraftEditorScreen({super.key});

  @override
  State<DraftEditorScreen> createState() => _DraftEditorScreenState();
}

class _DraftEditorScreenState extends State<DraftEditorScreen> {
  String? topic;
  String? style;
  String? tone;
  String? reference;

  bool isLoading = false;
  bool isEditing = false;

  List<TextEditingController> subtopicControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      topic = args['topic'];
      style = args['style'];
      tone = args['tone'];
      reference = args['reference'];
    }

    if (subtopicControllers.isEmpty) {
      _fetchInitialSubtopics();
    }
  }

Future<void> _fetchInitialSubtopics() async {
  setState(() => isLoading = true);

  final uri = Uri.parse('http://10.0.2.2:5000/api/task');
  final body = jsonEncode({
    'task_type': 'draft',
    'input_text': topic,
    'tone': tone,
    'reference_style': reference,
  });

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['result'];

      List<String> lines;

      if (result is String) {
        lines = result
            .split('\n')
            .map((line) => line.trim())
            .where((line) =>
                RegExp(r'^(#{1,3}\s*)?\d+(\.\d+)*\.?\s+').hasMatch(line))
            .map((line) => line.replaceAll(RegExp(r'^#{1,3}\s*'), '').trim())
            .toList();
      } else if (result is List) {
        lines = result.map((e) => e.toString()).toList();
      } else {
        lines = ["Unexpected response format"];
      }

      setState(() {
        subtopicControllers =
            lines.map((text) => TextEditingController(text: text)).toList();
      });
    } else {
      throw Exception("HTTP error ${response.statusCode}");
    }
  } catch (e) {
    setState(() {
      subtopicControllers = [
        TextEditingController(text: "Failed to load subtopics: $e")
      ];
    });
  } finally {
    setState(() => isLoading = false);
  }
}
  void _confirmAndProceed() {
    final editedSubtopics =
        subtopicControllers.map((c) => c.text.trim()).toList();

    Navigator.pushNamed(
      context,
      '/final',
      arguments: {
        'topic': topic,
        'style': style,
        'tone': tone,
        'reference': reference,
        'subtopics': editedSubtopics,
      },
    );
  }

  Widget _renderSubtopic(int index, TextEditingController controller) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Subtopic ${index + 1}",
            border: OutlineInputBorder(),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            controller.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: controller.text.contains('.') ? 16 : 18,
              fontWeight: controller.text.contains('.') ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Draft Outline", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!isLoading && subtopicControllers.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => isEditing = !isEditing),
              child: Text(isEditing ? "Done" : "Edit", style: const TextStyle(color: Colors.deepPurple)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              topic ?? '',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: subtopicControllers.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final controller = entry.value;
                      return _renderSubtopic(idx, controller);
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _confirmAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Subtopics"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
