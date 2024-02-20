import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteAI',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _audioUploaded = false;
  bool _slidesUploaded = false;

  void _navigateToFunctionsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FunctionsScreen()),
    );
  }

  void _navigateToSumAndNotesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SumAndNotesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Functions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FunctionButton(
              buttonText: 'Upload Record',
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (result != null) {
                  setState(() {
                    _audioUploaded = true;
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
                  child: Text('Done'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FunctionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Function'),
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
              buttonText: 'Sum',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SummarizationScreen()),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sum and Notes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FunctionButton(
              buttonText: 'Sum',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SummarizationScreen()),
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

class SummarizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summarization'),
      ),
      body: Center(
        child: Text('Here you can find the sum'),
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
        child: Text(buttonText),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 84, 98, 250), // Button color
          onPrimary: const Color.fromARGB(255, 252, 252, 252), // Text color
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      ),
    );
  }
}
