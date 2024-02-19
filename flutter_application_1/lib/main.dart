import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Processing Test',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _responseMessage = '';
  bool _isProcessing = false;

  Future<void> uploadAndProcessAudioFile() async {
    setState(() {
      _isProcessing = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/process-audio'),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'audio',
        file.bytes!,
        filename: file.name,
      ));

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          setState(() {
            _responseMessage = responseData['transcript'] ?? 'Transcription not available';
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to process audio file. Status code: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _responseMessage = 'Error: $e';
        });
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Processing Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isProcessing)
              CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : uploadAndProcessAudioFile,
              child: Text('Upload and Process Audio File'),
            ),
            SizedBox(height: 20),
            Text(_responseMessage),
          ],
        ),
      ),
    );
  }
}
