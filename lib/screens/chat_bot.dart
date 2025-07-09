import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user'|'ai', 'text': '...'}

  bool _isSending = false;
  String? initialPrompt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['initialPrompt'] != null && _messages.isEmpty) {
      initialPrompt = args['initialPrompt'] as String;
      _sendMessage(initialPrompt!);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      _messages.add({'role': 'user', 'text': text});
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.45:5000/api/ask"), // or 10.0.2.2
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': text}),
      );

      final result = jsonDecode(response.body);
      final aiResponse = result['answer'] ?? 'No answer received';

      setState(() {
        _messages.add({'role': 'ai', 'text': aiResponse});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Error: $e'});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message['text'] ?? '',
          style: GoogleFonts.inter(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
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
        title: const Text("AI Chat Assistant", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                return _buildMessage(_messages[reversedIndex]);
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration.collapsed(hintText: "Type your message..."),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(_isSending ? Icons.hourglass_top : Icons.send),
                  color: Colors.deepPurple,
                  onPressed: _isSending
                      ? null
                      : () {
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            _sendMessage(text);
                            _controller.clear();
                          }
                        },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
