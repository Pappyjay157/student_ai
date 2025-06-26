import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DraftScreen extends StatefulWidget {
  const DraftScreen({super.key});
  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  final _input = TextEditingController();
  String _task = 'draft';
  final List<String> options = ['summarize', 'draft', 'answer'];
  bool _loading = false;
  String output = '';
  final List<String> history = [];

  void _run() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    final resp = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/task'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'task_type':_task,'input_text':text}),
    );
    String result;
    if (resp.statusCode == 200) {
      result = jsonDecode(resp.body)['result']!;
    } else {
      result = 'Error ${resp.statusCode}:\n${resp.body}';
    }
    history.insert(0, "You ($_task):\n$text\nAI:\n$result");
    setState(() {
      _loading = false;
      output = '';
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Draft')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButton(value: _task, items: options.map((e)=>DropdownMenuItem(value:e,child: Text(e))).toList(),
            onChanged: (v)=>setState(()=>_task=v!)),
          const SizedBox(height:8),
          TextField(controller: _input, maxLines:4, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height:8),
          ElevatedButton(onPressed: _loading?null:_run, child: _loading ? const CircularProgressIndicator() : const Text('Run')),
          const SizedBox(height:12),
          Expanded(child: ListView.builder(itemCount: history.length, itemBuilder:(ctx,i)=>Padding(
            padding: const EdgeInsets.symmetric(vertical:8),
            child: Text(history[i], style: const TextStyle(fontSize:14))
          )))
        ]),
      ),
    );
  }
}
