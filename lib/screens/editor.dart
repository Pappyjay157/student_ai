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
  List<String> draftLines = [];

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
  }

  Future<void> _generateDraft() async {
    if (topic == null || style == null) return;

    setState(() {
      isLoading = true;
      draftLines = [];
    });

    final uri = Uri.parse('http://10.0.2.2:5000/api/task');
    final body = jsonEncode({
      'task_type': style,
      'input_text': topic,
      'tone': tone ?? 'Formal',
      'reference_style': reference ?? 'APA',
      'structure': "numbered outline"
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = (data['result'] ?? "No content generated.") as String;
        setState(() {
        draftLines = raw
            .split('\n')
            .map((line) => line.toString())
            .where((line) => line.trim().isNotEmpty)
            .toList();
        });
      } else {
        setState(() {
          draftLines = ["Server error: ${response.statusCode}", response.body];
        });
      }
    } catch (e) {
      setState(() {
        draftLines = ["Error:", e.toString()];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _renderLine(String line) {
    line = line.trim();
    if (RegExp(r"^\d+\.\s").hasMatch(line)) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          line,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (line.toLowerCase().startsWith("introduction") ||
        line.toLowerCase().startsWith("conclusion")) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          line,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      );
    } else if (line.length < 40) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          line,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          line,
          style: GoogleFonts.inter(fontSize: 15),
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
        title: Text(
          "Draft Editor",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : draftLines.isEmpty
                        ? const Center(child: Text("Press 'Generate' to start."))
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: draftLines.map(_renderLine).toList(),
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _generateDraft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Generate Draft"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
