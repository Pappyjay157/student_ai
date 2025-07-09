import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WritingPreferencesScreen extends StatefulWidget {
  const WritingPreferencesScreen({super.key});

  @override
  State<WritingPreferencesScreen> createState() => _WritingPreferencesScreenState();
}

class _WritingPreferencesScreenState extends State<WritingPreferencesScreen> {
  final List<String> _tones = [
    "Formal", "Informative", "Objective", "Analytical", "Persuasive",
    "Narrative", "Descriptive", "Casual"
  ];

  final List<String> _references = [
    "No, thanks", "MLA", "APA", "IEEE", "AMA", "ACS", "Chicago", "Harvard", "Vancouver"
  ];

  String? selectedTone;
  String? selectedReference = "No, thanks";

  String taskType = "essay";
  late String topic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      topic = args['topic'];
      taskType = args['task_type'];
    }
  }

  void _goToDraftEditor() {
    if (selectedTone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a tone")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/editor',
      arguments: {
        'topic': topic,
        'task_type': taskType,
        'tone': selectedTone,
        'reference': selectedReference ?? "No, thanks",
      },
    );
  }

  Widget _buildChipList(List<String> items, String? selected, Function(String) onTap) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selected == item;
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onTap(item),
          selectedColor: Colors.deepPurple,
          backgroundColor: Colors.grey[200],
          labelStyle: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Writing Preferences"),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How should it sound?", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildChipList(_tones, selectedTone, (val) => setState(() => selectedTone = val)),

            const SizedBox(height: 32),

            // Only show references if task is essay
            if (taskType == 'essay') ...[
              Text("Need references in your work?", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildChipList(_references, selectedReference, (val) => setState(() => selectedReference = val)),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _goToDraftEditor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
