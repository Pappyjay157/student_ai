import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadNotesScreen extends StatefulWidget {
  const UploadNotesScreen({super.key});
  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState();
}

class _UploadNotesScreenState extends State<UploadNotesScreen> {
  String _message = '';
  bool _loading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result == null) return;
    setState(() => _loading = true);

    final file = result.files.first;
    final request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/api/upload'));
    request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));

    final resp = await request.send();
    final body = await resp.stream.bytesToString();
    setState(() {
      _loading = false;
      _message = resp.statusCode == 200 ? 'Uploaded successfully!' : 'Error ${resp.statusCode}:\n$body';
    });
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton(onPressed: _loading ? null : _pickAndUpload, child: const Text('Choose & Upload .txt File')),
          if (_loading) const CircularProgressIndicator(),
          if (_message.isNotEmpty) Padding(padding: const EdgeInsets.only(top:16), child: Text(_message)),
        ]),
      ),
    );
  }
}
