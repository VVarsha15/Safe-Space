import 'package:flutter/material.dart';
import 'dart:async';
import '../services/socket_service.dart';

class HeartRateMonitorPage extends StatefulWidget {
  @override
  _HeartRateMonitorPageState createState() => _HeartRateMonitorPageState();
}

class _HeartRateMonitorPageState extends State<HeartRateMonitorPage>
    with SingleTickerProviderStateMixin {
  int _currentBPM = 0;
  bool _isFearDetected = false;
  List<int> _bpmHistory = [];
  bool _connected = false;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for heart pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _pulseController.repeat(reverse: true);
    
    // Make sure the socket is initialized
    if (!SocketService.isConnected) {
      print("Socket not connected, initializing...");
      SocketService.initSocket();
    } else {
      print("Socket already connected");
    }
    
    // Set up the callback
    print("Setting up heart rate callback");
    SocketService.setHeartRateCallback((data) {
      print("Received callback data: $data");
      final bpm = data['bpm'];
      if (bpm != null) {
        // If data contains floating point number, convert to int
        final parsedBpm = bpm is double ? bpm.toInt() : bpm;
        print("Setting state with BPM: $parsedBpm");
        
        setState(() {
          _currentBPM = parsedBpm;
          _isFearDetected = data['fear'] ?? false;
          _connected = true;
          
          // Add to history, keep only last 20 readings
          _bpmHistory.add(_currentBPM);
          if (_bpmHistory.length > 20) {
            _bpmHistory.removeAt(0);
          }
        });
      } else {
        print("Received data without BPM: $data");
      }
    });
    
    // Initial data if not connected yet
    if (_bpmHistory.isEmpty) {
      _bpmHistory = [72, 74, 73, 75, 76, 74, 72];
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors from your app
    final primary = Theme.of(context).primaryColor;
    final primaryDark = Color(0xFF5E18AA); // Darker shade of your purple
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Heart Rate Monitor"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print("Refreshing socket connection");
              SocketService.initSocket();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Reconnecting to server..."))
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, primaryDark],
          ),
        ),
        child: Column(
          children: [
            // Alert bar for fear detection
            if (_isFearDetected)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.red,
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Potential stress detected in your heart rate pattern!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main heart rate display
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated heart icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.2),
                              child: Icon(
                                Icons.favorite,
                                size: 120,
                                color: _isFearDetected
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32),

                    // BPM display
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_currentBPM',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'BEATS PER MINUTE',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Connection status
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _connected
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _connected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_searching,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _connected
                                ? 'Connected to sensor'
                                : 'Waiting for sensor...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                   
                  ],
                ),
              ),
            ),

            // Heart rate chart
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _bpmHistory.isEmpty
                  ? Center(
                      child: Text('No data yet',
                          style: TextStyle(color: Colors.white70)))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: HeartRateChartPainter(
                          dataPoints: _bpmHistory,
                          lineColor: Colors.white,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
            ),

            // Status card
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                _getHeartRateStatusText(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _getStatusColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _getStatusDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_isFearDetected)
                    Container(
                      color: Colors.red.withOpacity(0.1),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stress Detection Alert',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your heart rate pattern indicates potential stress or fear. Consider taking a moment to breathe deeply and check your surroundings.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                icon: Icon(Icons.call, size: 16),
                                label: Text('Call Contact'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                ),
                                onPressed: () {
                                  // Call emergency contact
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling emergency contact...'))
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.check_circle, size: 16),
                                label: Text('I\'m Safe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  // Mark as safe
                                  setState(() {
                                    _isFearDetected = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHeartRateStatusText() {
    if (_currentBPM == 0) {
      return 'No heartbeat detected';
    } else if (_currentBPM < 60) {
      return 'Low Heart Rate';
    } else if (_currentBPM <= 100) {
      return 'Normal Heart Rate';
    } else if (_currentBPM <= 140) {
      return 'Elevated Heart Rate';
    } else {
      return 'High Heart Rate';
    }
  }

  String _getStatusDescription() {
    if (_currentBPM == 0) {
      return 'Make sure the sensor is properly connected and positioned correctly.';
    } else if (_currentBPM < 60) {
      return 'Your heart rate is below the normal resting rate. This could be normal for athletes, but consult a doctor if you feel unwell.';
    } else if (_currentBPM <= 100) {
      return 'Your heart rate is within the normal range. Keep monitoring for any sudden changes.';
    } else if (_currentBPM <= 140) {
      return 'Your heart rate is elevated. This could be due to exercise, stress, or anxiety. Take a moment to breathe deeply.';
    } else {
      return 'Your heart rate is very high. Unless you\'re exercising, consider sitting down, taking deep breaths, and monitoring for other symptoms.';
    }
  }

  Color _getStatusColor() {
    if (_currentBPM == 0) {
      return Colors.grey;
    } else if (_currentBPM < 60) {
      return Colors.blue;
    } else if (_currentBPM <= 100) {
      return Colors.green;
    } else if (_currentBPM <= 140) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    if (_currentBPM == 0) {
      return Icons.help_outline;
    } else if (_currentBPM < 60) {
      return Icons.arrow_downward;
    } else if (_currentBPM <= 100) {
      return Icons.check_circle_outline;
    } else if (_currentBPM <= 140) {
      return Icons.trending_up;
    } else {
      return Icons.warning_amber_rounded;
    }
  }
}

class HeartRateChartPainter extends CustomPainter {
  final List<int> dataPoints;
  final Color lineColor;
  final Color fillColor;

  HeartRateChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Find the max and min values for scaling
    final maxBPM = dataPoints.reduce((curr, next) => curr > next ? curr : next).toDouble();
    final minBPM = dataPoints.reduce((curr, next) => curr < next ? curr : next).toDouble();

    // Scale the height to the available space with some padding
    final diff = (maxBPM - minBPM);
    final yScale = (size.height - 20) / (diff < 10 ? 20 : diff);

    // Width between points
    final xScale = size.width / (dataPoints.length - 1).clamp(1, double.infinity);

    final path = Path();
    final fillPath = Path();

    // Start paths
    path.moveTo(0, size.height - ((dataPoints[0] - minBPM) * yScale) - 10);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - ((dataPoints[0] - minBPM) * yScale) - 10);

    // Draw points with curved lines
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * xScale;
      final y = size.height - ((dataPoints[i] - minBPM) * yScale) - 10;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        // For a smoother curve, use quadratic bezier
        final prevX = (i - 1) * xScale;
        final prevY = size.height - ((dataPoints[i - 1] - minBPM) * yScale) - 10;
        
        final controlX = (prevX + x) / 2;
        
        path.quadraticBezierTo(controlX, prevY, x, y);
        fillPath.quadraticBezierTo(controlX, prevY, x, y);
      }
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw the paths
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots at each data point
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * xScale;
      final y = size.height - ((dataPoints[i] - minBPM) * yScale) - 10;
      
      // Draw only some dots for cleaner look
      if (i % 3 == 0 || i == dataPoints.length - 1) {
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}