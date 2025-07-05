import 'package:flutter/material.dart';
import 'forum_page.dart';
import 'enter_experience_page.dart';
import 'gps_tracker_page.dart';
import 'heart_rate_monitor_page.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom app bar
            _buildAppBar(context),
            
            // Welcome section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to SafeSpace',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your personal safety companion',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            
            // Features grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      title: 'Heart Rate\nMonitor',
                      icon: Icons.favorite,
                      gradient: [Color(0xFFFF5E7D), Color(0xFFFF005B)],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HeartRateMonitorPage()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'GPS Safety\nTracker',
                      icon: Icons.location_on,
                      gradient: [Color(0xFF4286F4), Color(0xFF373BFF)],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GpsTrackerPage()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Community\nForum',
                      icon: Icons.forum,
                      gradient: [Color(0xFF43E695), Color(0xFF3BB2B8)],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SafetyForumPage()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Share Your\nExperience',
                      icon: Icons.add_comment,
                      gradient: [Color(0xFFFFB02E), Color(0xFFFF7C18)],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EnterExperiencePage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Safety tips card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Card(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Color(0xFF3A0CA3)),
                          SizedBox(width: 8),
                          Text(
                            'Safety Tip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF3A0CA3),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Always let someone know where you\'re going, especially when traveling alone.',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'SafeSpace',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.grey[700]),
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: Colors.white,
                ),
                Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
}