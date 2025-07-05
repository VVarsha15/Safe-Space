import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SafeSpace")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Welcome to SafeSpace", style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: Text("Safety Forum")),
            ElevatedButton(onPressed: () {}, child: Text("Share Your Experience")),
            ElevatedButton(onPressed: () {}, child: Text("GPS Tracker")),
          ],
        ),
      ),
    );
  }
}
