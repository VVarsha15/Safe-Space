import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await ApiService.login(phoneController.text, passwordController.text);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result.containsKey('token') && !result.containsKey('error')) {
        // Login successful - navigate to home screen
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => HomeScreen())
        );
      } else if (result['message']?.contains('not found') == true) {
        // User not found - offer to sign up
        _showSignupDialog();
      } else {
        // Other login error
        _showDialog(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error connecting to server: $e');
    }
  }

  void _showSignupDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Account Not Found"),
        content: Text("Would you like to create a new account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => SignupScreen())
              );
            }, 
            child: Text("Sign Up")
          ),
        ],
      )
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Login Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("OK")
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo and title
                  Container(
                    margin: EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shield,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'SafeSpace',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Personal Safety Companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Login form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Log In',
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32),
                            _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Text(
                                      "LOG IN",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Sign up link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignupScreen()),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}