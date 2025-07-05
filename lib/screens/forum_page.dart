import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SafetyForumPage extends StatefulWidget {
  @override
  _SafetyForumPageState createState() => _SafetyForumPageState();
}

class _SafetyForumPageState extends State<SafetyForumPage> {
  List<Map<String, dynamic>> _experiences = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }
  
  Future<void> _loadExperiences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final experiences = await ApiService.getExperiences();
      setState(() {
        _experiences = List<Map<String, dynamic>>.from(experiences);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading experiences: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load experiences')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Safety Forum')),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadExperiences,
            child: _experiences.isEmpty
              ? Center(child: Text('No experiences shared yet'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _experiences.length,
                  itemBuilder: (context, index) {
                    final post = _experiences[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['name'] ?? '', 
                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 8),
                            Text(post['story'] ?? ''),
                            SizedBox(height: 8),
                            Text(
                              'Posted: ${_formatDate(post['createdAt'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

/// Function to add experience (needed for other files)
void addExperience(String name, String story) async {
  try {
    await ApiService.addExperience(name, story);
  } catch (e) {
    print('Error adding experience: $e');
  }
}