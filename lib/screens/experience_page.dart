import 'package:flutter/material.dart';

class ExperiencePage extends StatefulWidget {
  @override
  _ExperiencePageState createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  final TextEditingController _controller = TextEditingController();
  String message = '';

  void publishExperience() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        message = "Your experience has been published!";
        _controller.clear();
      });
    } else {
      setState(() {
        message = "Please enter a description.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share Your Experience")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Describe your experience...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: publishExperience,
              child: Text("Publish"),
            ),
            SizedBox(height: 20),
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
