import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio and Slides File Upload',
      home: FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _audioFilePath;
  String? _pdfFilePath;

  Future<void> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFilePath = result.files.single.path;
      });
    }
  }

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFilePath = result.files.single.path;
      });
    }
  }

  void navigateToSummaryScreen() {
    if (_audioFilePath != null && _pdfFilePath != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SummaryScreen(audioFilePath: _audioFilePath!, pdfFilePath: _pdfFilePath!),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio and Slides File Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickAudioFile,
              child: Text('Upload Audio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickPdfFile,
              child: Text('Upload Slides'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToSummaryScreen,
              child: Text('Process and Align'),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatefulWidget {
  final String audioFilePath;
  final String pdfFilePath;

  SummaryScreen({required this.audioFilePath, required this.pdfFilePath});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isLoading = true;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    uploadAndProcessFiles();
  }

  Future<void> uploadAndProcessFiles() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.116.6.142:5000/align-slides'), // Update this with your backend URL
    );

    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      widget.audioFilePath,
    ));
    request.files.add(await http.MultipartFile.fromPath(
      'slides',
      widget.pdfFilePath,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/result.pdf");
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        print('Failed to process files: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processed File'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _localFilePath != null
              ? PDFView(filePath: _localFilePath)
              : Center(child: Text('No file to display')),
    );
  }
}
