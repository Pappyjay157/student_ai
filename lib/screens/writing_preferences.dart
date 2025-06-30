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
  String? selectedReference;

  late String topic;
  late String style;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      topic = args['topic'];
      style = args['style'];
    }
  }

  void _goToDraftEditor() {
    if (selectedTone == null || selectedReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select tone and reference style")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/draft',
      arguments: {
        'topic': topic,
        'style': style,
        'tone': selectedTone,
        'reference': selectedReference,
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
      appBar: AppBar(title: const Text("Step 2: Preferences")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How should it sound?", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildChipList(_tones, selectedTone, (val) => setState(() => selectedTone = val)),

            const SizedBox(height: 32),
            Text("Need references in your work?", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildChipList(_references, selectedReference, (val) => setState(() => selectedReference = val)),

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
