import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color customBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sum&Note',
      theme: ThemeData(
        // Apply the custom color as the background color for all Scaffolds
        scaffoldBackgroundColor: customBackgroundColor,
        appBarTheme: AppBarTheme(
          color:
              customBackgroundColor, // Optional: also change the AppBar color to match
        ),
      ),
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
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 300, width: 300, // Set this height to fit your layout
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/notAI3.png'),
                  fit: BoxFit
                      .cover, // Use BoxFit.cover to keep the image's aspect ratio.
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
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 252, 252, 252),
          backgroundColor: Color.fromARGB(255, 33, 129, 183), // Text color
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
