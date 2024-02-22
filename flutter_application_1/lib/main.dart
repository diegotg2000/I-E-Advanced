import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio File Upload and Display Summary',
      home: FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _filePath;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  void navigateToSummarizeScreen() {
    if (_filePath != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SummarizeScreen(filePath: _filePath!),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio File Upload and Display Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickFile,
              child: Text('Upload Audio'),
            ),
            SizedBox(height: 20),
            if (_filePath != null)
              ElevatedButton(
                onPressed: navigateToSummarizeScreen,
                child: Text('Go'),
              ),
          ],
        ),
      ),
    );
  }
}

class SummarizeScreen extends StatelessWidget {
  final String filePath;

  SummarizeScreen({required this.filePath});

  void navigateToSummaryScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SummaryScreen(filePath: filePath),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prepare to Summarize'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => navigateToSummaryScreen(context),
          child: Text('Summarize!'),
        ),
      ),
    );
  }
}

class SummaryScreen extends StatefulWidget {
  final String filePath;

  SummaryScreen({required this.filePath});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _summary = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    uploadAndProcessFile();
  }

  Future<void> uploadAndProcessFile() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.116.6.142:5000/process-audio/'), // Replace with your actual backend URL
    );

    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      widget.filePath,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _summary = responseData['summary'] ?? 'No summary available';
      } else {
        _summary = 'Failed to upload file: ${response.statusCode}';
      }
    } catch (e) {
      _summary = 'Error: $e';
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
        title: Text('Audio Summary'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Text(_summary),
      ),
    );
  }
}
