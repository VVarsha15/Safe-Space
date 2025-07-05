import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class GpsTrackerPage extends StatefulWidget {
  @override
  _GpsTrackerPageState createState() => _GpsTrackerPageState();
}

class _GpsTrackerPageState extends State<GpsTrackerPage> {
  String _location = 'Fetching location...';
  bool _loading = true;
  bool _isDangerArea = false;
  String _dangerInfo = '';
  double _latitude = 13.0318336;  // Default coordinate for demo
  double _longitude = 80.2127872; // Default coordinate for demo

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _location = 'Fetching location...';
    });

    // Simulate fetching location for demo
    await Future.delayed(Duration(seconds: 2));
    
    setState(() {
      // Use default coordinates for Chennai
      _latitude = 13.0318336;
      _longitude = 80.2127872;
      _location = 'Latitude: $_latitude, Longitude: $_longitude';
      _loading = false;
    });
    
    // Check if in danger area
    _checkDangerArea(_latitude, _longitude);
  }
  
  Future<void> _checkDangerArea(double latitude, double longitude) async {
    try {
      final result = await ApiService.checkDangerArea(latitude, longitude);
      
      setState(() {
        _isDangerArea = result['isDangerous'] == true;
        if (_isDangerArea) {
          _dangerInfo = 'Ward: ${result['wardNumber'] ?? 'N/A'}, Locality: ${result['locality'] ?? 'N/A'}, Safety Score: ${result['safetyScore'] ?? 'N/A'}';
        } else {
          _dangerInfo = '';
        }
      });
    } catch (e) {
      print('Error checking danger area: $e');
      setState(() {
        _isDangerArea = false;
        _dangerInfo = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Tracker")),
      body: Column(
        children: [
          // Simple map visualization
          Expanded(
            flex: 3,
            child: _loading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Background map (could be replaced with an actual image)
                    Container(
                      color: Colors.blueGrey[200],
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                    
                    // Center marker
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _isDangerArea ? Colors.red : Colors.green,
                            size: 50,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Your Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Map controls
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {}, // Zoom in functionality would go here
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {}, // Zoom out functionality would go here
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
          
          // Location info and warnings
          Container(
            padding: EdgeInsets.all(16),
            color: _isDangerArea ? Colors.red.shade100 : Colors.green.shade100,
            child: Column(
              children: [
                Text(
                  _isDangerArea ? 'WARNING: High Risk Area' : 'Status: Safe Area',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDangerArea ? Colors.red[700] : Colors.green[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(_location, style: TextStyle(fontSize: 14)),
                if (_dangerInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_dangerInfo, style: TextStyle(fontSize: 14)),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getLocation,
                  child: Text('Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to create a grid that looks like a map
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    
    // Draw horizontal lines
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
      y += 20;
    }
    
    // Draw vertical lines
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
      x += 20;
    }
    
    // Draw some "roads"
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    
    // Main horizontal road
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      roadPaint,
    );
    
    // Main vertical road
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      roadPaint,
    );
    
    // Additional roads
    canvas.drawLine(
      Offset(size.width / 4, 0),
      Offset(size.width / 4, size.height),
      roadPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 3 / 4, 0),
      Offset(size.width * 3 / 4, size.height),
      roadPaint,
    );
    
    canvas.drawLine(
      Offset(0, size.height / 4),
      Offset(size.width, size.height / 4),
      roadPaint,
    );
    
    canvas.drawLine(
      Offset(0, size.height * 3 / 4),
      Offset(size.width, size.height * 3 / 4),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}