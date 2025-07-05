import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EnterExperiencePage extends StatefulWidget {
  @override
  _EnterExperiencePageState createState() => _EnterExperiencePageState();
}

class _EnterExperiencePageState extends State<EnterExperiencePage> {
  final nameController = TextEditingController();
  final storyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  void _submitStory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = nameController.text.trim();
    final story = storyController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.addExperience(name, story);
      
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your story has been published.')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish story. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share Your Experience")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: TextFormField(
                  controller: storyController,
                  decoration: InputDecoration(
                    labelText: "Describe your experience",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your experience';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitStory,
                    child: Text("Publish"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    storyController.dispose();
    super.dispose();
  }
}