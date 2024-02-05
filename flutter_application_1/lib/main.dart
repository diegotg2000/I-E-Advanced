import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Function App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Functions'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FunctionButton(
              buttonText: 'Summarize',
              onPressed: () {
                // Logic for Summarize button
              },
            ),
            FunctionButton(
              buttonText: 'Notes',
              onPressed: () {
                // Logic for Notes button
              },
            ),
            FunctionButton(
              buttonText: 'Align with slides',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AlignWithSlidesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AlignWithSlidesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Align with Slides'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  PlatformFile file = result.files.first;
                  print(file.name);
                  // Now you can use the file.name and file.bytes or file.path to upload or use the file
                } else {
                  // User canceled the picker
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
                  PlatformFile file = result.files.first;
                  print(file.name);
                  // Similarly, use the file as needed for upload or processing
                } else {
                  // User canceled the picker
                }
              },
            ),
          ],
        ),
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
          primary: Colors.grey[300], // Button color
          onPrimary: Colors.black, // Text color
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      ),
    );
  }
}
