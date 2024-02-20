import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
<<<<<<< Updated upstream
=======
import 'package:http/http.dart' as http;
>>>>>>> Stashed changes
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< Updated upstream
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Processing Test',
=======
  final Color customBackgroundColor = Color.fromARGB(255, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sum&Note',
      theme: ThemeData(
        scaffoldBackgroundColor: customBackgroundColor,
        appBarTheme: AppBarTheme(
          color: customBackgroundColor,
        ),
      ),
>>>>>>> Stashed changes
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< Updated upstream
  String _responseMessage = '';
  bool _isProcessing = false;

  Future<void> uploadAndProcessAudioFile() async {
    setState(() {
      _isProcessing = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
=======
  bool _audioUploaded = false;
  bool _slidesUploaded = false;
  PlatformFile? _selectedAudioFile;

  void _navigateToFunctionsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FunctionsScreen(audioFile: _selectedAudioFile)),
    );
  }

  void _navigateToSumAndNotesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SumAndNotesScreen(audioFile: _selectedAudioFile)),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
            if (_isProcessing)
              CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : uploadAndProcessAudioFile,
              child: Text('Upload and Process Audio File'),
            ),
            SizedBox(height: 20),
            Text(_responseMessage),
=======
            Container(
              height: 300, width: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/notAI3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            FunctionButton(
              buttonText: 'Upload Record',
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (result != null) {
                  setState(() {
                    _audioUploaded = true;
                    _selectedAudioFile = result.files.first;
                  });
                }
              },
            ),
            FunctionButton(
              buttonText: 'Upload Slides',
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'ppt', 'pptx'],
                );
                if (result != null) {
                  setState(() {
                    _slidesUploaded = true;
                  });
                }
              },
            ),
            if (_audioUploaded || _slidesUploaded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_audioUploaded && _slidesUploaded) {
                      _navigateToFunctionsScreen();
                    } else {
                      _navigateToSumAndNotesScreen();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 33, 183, 121),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text('Go'),
                ),
              ),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}
<<<<<<< Updated upstream
=======

class FunctionsScreen extends StatelessWidget {
  final PlatformFile? audioFile;

  FunctionsScreen({Key? key, this.audioFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What do you need to do?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FunctionButton(
              buttonText: 'Notes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesScreen()),
                );
              },
            ),
            FunctionButton(
              buttonText: 'Summarization',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SummarizationScreen(audioFile: audioFile)),
                );
              },
            ),
            FunctionButton(
              buttonText: 'Align with Slides',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlignmentScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SumAndNotesScreen extends StatelessWidget {
  final PlatformFile? audioFile;

  SumAndNotesScreen({Key? key, this.audioFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summarize and Notes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FunctionButton(
              buttonText: 'Summarize',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SummarizationScreen(audioFile: audioFile)),
                );
              },
            ),
            FunctionButton(
              buttonText: 'Notes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SummarizationScreen extends StatefulWidget {
  final PlatformFile? audioFile;

  SummarizationScreen({Key? key, this.audioFile}) : super(key: key);

  @override
  _SummarizationScreenState createState() => _SummarizationScreenState();
}

class _SummarizationScreenState extends State<SummarizationScreen> {
  String _responseMessage = 'Processing...';
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    if (widget.audioFile != null) {
      processAudioFile();
    } else {
      setState(() {
        _responseMessage = 'No audio file selected.';
        _isProcessing = false;
      });
    }
  }

  Future<void> processAudioFile() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:5000/process-audio/'),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'audio',
      widget.audioFile!.bytes!,
      filename: widget.audioFile!.name,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() {
          _responseMessage = responseData['summary'] ?? 'Transcription not available';
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
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summarization'),
      ),
      body: Center(
        child: _isProcessing
          ? CircularProgressIndicator()
          : Text(_responseMessage),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: Center(
        child: Text('Here you can find the notes'),
      ),
    );
  }
}

class AlignmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alignment Example'),
      ),
      body: Center(
        child: Text('Here the alignments'),
      ),
    );
  }
}

class FunctionButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  FunctionButton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 252, 252, 252),
          backgroundColor: Color.fromARGB(255, 33, 129, 183),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
>>>>>>> Stashed changes
