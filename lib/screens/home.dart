import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  String selectedTaskType = 'essay';

  final List<String> writingModes = ['essay', 'summary', 'chat'];

  final List<String> _suggestedTopics = [
    "The Influence of Artificial Intelligence on Job Markets",
    "Renewable Energy Solutions for Urban Environments",
    "The Psychological Effects of Social Media on Teenagers",
    "Exploring the Ethics of Genetic Engineering",
    "The Role of Space Exploration in Scientific Advancement"
  ];

  String selectedTone = 'Formal'; // pulled from writing preference screen
  String selectedReference = 'APA'; // pulled from writing preference screen

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
    if (selectedTaskType == 'chat') {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'initialPrompt': topic,
      },
    );
  } else {
    Navigator.pushNamed(
      context,
      '/preferences',
      arguments: {
        'topic': topic,
        'task_type': selectedTaskType,
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
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
                "Jumpstart your writing with AI-powered ideas",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Writing Mode Pill Selector
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: writingModes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final mode = writingModes[index];
                    final isSelected = selectedTaskType == mode;

                    return GestureDetector(
                      onTap: () => setState(() => selectedTaskType = mode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        child: Text(
                          mode[0].toUpperCase() + mode.substring(1),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.deepPurple,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ✍️ Topic Input Box
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

              // 🎯 Suggested Topics
              Text(
                "Suggested topics",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
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

              // 🚀 Continue Button
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
                  child: const Text("Get Started"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
