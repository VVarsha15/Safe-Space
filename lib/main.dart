import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Socket service
  SocketService.initSocket();
  runApp(SafeSpaceApp());
}

class SafeSpaceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color(0xFF7B2CBF),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF7B2CBF),
          secondary: Color(0xFFE0AAFF),
          surface: Colors.white,
          background: Color(0xFFF8F9FA),
          error: Colors.red[700]!,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
  displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A0CA3)),  // was headline1
  displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3A0CA3)),  // was headline2
  displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3A0CA3)),  // was headline3
  bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),  // was bodyText1
  bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),  // was bodyText2
  labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),  // was button
),
      ),
      home: LoginScreen(),
    );
  }
}