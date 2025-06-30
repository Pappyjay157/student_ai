import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final List<String> _styles = ['Essay', 'Literature Review'];
  int _selectedIndex = 0;

  final List<String> _suggestedTopics = [
    "Analyze the theme of revenge in Shakespeare's Hamlet",
    "The Impact of COVID-19 Lockdown on Parents' Mental Health",
    "Factors Influencing Companies' Compensation Strategies",
    "The Role of Social Media in Modern Society",
    "Ethical Considerations in Research Participation"
  ];

  void _onTopicTap(String topic) {
    _topicController.text = topic;
  }

  void _continueToDraft() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a topic')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/preferences',
      arguments: {
        'topic': topic,
        'style': _styles[_selectedIndex].toLowerCase()
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Undetectable AI Writer",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "🚀 Jumpstart your writing with AI-powered ideas",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Writing Style Toggle
              ToggleButtons(
                isSelected: List.generate(_styles.length, (i) => i == _selectedIndex),
                onPressed: (index) {
                  setState(() => _selectedIndex = index);
                },
                borderRadius: BorderRadius.circular(20),
                selectedColor: Colors.white,
                fillColor: Colors.deepPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                children: _styles.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(e),
                )).toList(),
              ),

              const SizedBox(height: 24),

              // Input box with elevation
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  controller: _topicController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter your topic here...",
                    hintStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.all(20),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Suggested topics",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Suggested Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedTopics.map((topic) {
                  return ActionChip(
                    label: Text(topic, style: GoogleFonts.inter(fontSize: 13)),
                    onPressed: () => _onTopicTap(topic),
                    backgroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  );
                }).toList(),
              ),

              const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _continueToDraft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text("Generate Draft"),
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}
