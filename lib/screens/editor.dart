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
  String? taskType;

  bool isLoading = false;
  List<TextEditingController> subtopicControllers = [];
  Set<int> editingIndices = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      topic = args['topic'];
      taskType = args['task_type'];
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
      'task_type': taskType,
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
          if (taskType == 'essay') {
            lines = result
                .split('\n')
                .map((line) => line.trim())
                .where((line) =>
                    RegExp(r'^(#{1,3}\s*)?\d+(\.\d+)*\.?\s+').hasMatch(line))
                .map((line) =>
                    line.replaceAll(RegExp(r'^#{1,3}\s*'), '').trim())
                .toList();
          } else if (['summary'].contains(taskType)) {
            lines = [result];
          } else if (taskType == 'chat') {
            lines = result
                .split('\n')
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty)
                .toList();
          } else {
            lines = [result];
          }
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
  return GestureDetector(
    onTap: () {
      setState(() {
        editingIndices.add(index);
      });
    },
    child: editingIndices.contains(index)
        ? Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  setState(() => editingIndices.remove(index));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: controller,
                  maxLines: null, // expands vertically
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: const InputDecoration.collapsed(
                    hintText: "Edit text...",
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: controller.text.contains('.') ? 16 : 18,
                  fontWeight: controller.text.contains('.')
                      ? FontWeight.w500
                      : FontWeight.w700,
                ),
              ),
            ),
          ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          taskType == 'chat'
              ? "Conversation Draft"
                  : taskType == 'summary'
                      ? "Summary Outline"
                      : "Essay Outline",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              topic ?? '',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 26),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: subtopicControllers
                        .asMap()
                        .entries
                        .map((entry) =>
                            _renderSubtopic(entry.key, entry.value))
                        .toList(),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
