import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student AI Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StudentAssistantHome(),
    );
  }
}

class StudentAssistantHome extends StatefulWidget {
  const StudentAssistantHome({super.key});

  @override
  State<StudentAssistantHome> createState() => _StudentAssistantHomeState();
}

class _StudentAssistantHomeState extends State<StudentAssistantHome> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedTask = 'Summarize';
  String _result = '';
  bool _isLoading = false;

  final List<String> _taskOptions = ['Summarize', 'Draft', 'Answer'];

  void _submitTask() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final input = _inputController.text.trim();
    final task = _selectedTask.toLowerCase(); // 'summarize', 'draft', 'answer'

    if (input.isEmpty) {
      setState(() {
        _isLoading = false;
        _result = 'Please enter a question or task.';
      });
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/api/task');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task_type': task, 'input_text': input}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['result'] ?? 'No response received.';
          _inputController.clear();
        });
      } else {
        setState(() {
          _result = 'Error ${response.statusCode}:\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Failed to connect to server:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedTask,
              items: _taskOptions.map((task) {
                return DropdownMenuItem<String>(
                  value: task,
                  child: Text(task),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTask = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your question or task...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
