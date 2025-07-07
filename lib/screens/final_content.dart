import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class FinalContentScreen extends StatefulWidget {
  const FinalContentScreen({super.key});

  @override
  State<FinalContentScreen> createState() => _FinalContentScreenState();
}

class _FinalContentScreenState extends State<FinalContentScreen> {
  String? topic;
  String? style;
  String? tone;
  String? reference;
  List<String> subtopics = [];

  bool isLoading = true;
  bool isRegenerating = false;
  TextEditingController contentController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      topic = args['topic'];
      style = args['style'];
      tone = args['tone'];
      reference = args['reference'];
      subtopics = List<String>.from(args['subtopics'] ?? []);
      _generateFullContent(); // Fetch AI draft
    }
  }

  Future<void> _generateFullContent() async {
    setState(() {
      isLoading = true;
    });

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
        final raw = jsonDecode(response.body)['result'] ?? '';
        contentController.text = raw.trim();
      } else {
        contentController.text = "Failed to generate content. Try again.";
      }
    } catch (e) {
      contentController.text = "Error: $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _downloadAsPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(topic ?? 'AI Draft', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text(contentController.text, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$topic.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloaded to: ${file.path}'),
    ));
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: contentController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("Final Draft", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                    topic ?? '',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      maxLines: null,
                      expands: true,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateFullContent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: isRegenerating
                              ? const CircularProgressIndicator()
                              : const Text("Regenerate"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _copyToClipboard,
                        tooltip: "Copy All",
                        icon: const Icon(Icons.copy, color: Colors.deepPurple),
                      ),
                      IconButton(
                        onPressed: _downloadAsPdf,
                        tooltip: "Download as PDF",
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
