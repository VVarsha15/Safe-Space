import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Controllers for all fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  
  String? _relation;
  bool _obscurePassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      _showDialog('Passwords do not match');
      print("Passwords don't match");
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'age': int.parse(ageController.text),
        'password': passwordController.text,
        'emergencyContact': {
          'name': emergencyNameController.text,
          'phone': emergencyPhoneController.text,
          'relation': _relation,
        }
      };
      
      print("Sending registration data: $userData");
      final result = await ApiService.register(userData);
      print("Registration response: $result");
      
      setState(() {
        _isLoading = false;
      });
      
      // Check for error first - this is important!
      if (result.containsKey('error') && result['error'] == true) {
        print("Registration error: ${result['message']}");
        _showDialog(result['message'] ?? 'Registration failed');
        return;
      }
      
      // Success case - token present and no error
      if (result.containsKey('token')) {
        print("Registration successful, token: ${result['token']}");
        
        // Token is already stored in the ApiService.register method
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        
        // Use a short delay to ensure the snackbar is seen
        await Future.delayed(Duration(milliseconds: 1200));
        
        if (!mounted) return;
        
        print("Navigating to home screen");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      } else {
        // This catches cases where there's no error flag but also no token
        print("Unexpected response format: $result");
        _showDialog('Unexpected response from server. Please try again.');
      }
    } catch (e) {
      print("Exception during registration: $e");
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error connecting to server: $e');
    }
  }
  
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Registration Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              final isLastStep = _currentStep == 2;
              if (isLastStep) {
                _register();
              } else {
                setState(() {
                  _currentStep += 1;
                });
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            controlsBuilder: (context, details) {
              final isLastStep = _currentStep == 2;
              
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        child: _isLoading && isLastStep
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('PROCESSING...'),
                                ],
                              )
                            : Text(isLastStep ? 'SUBMIT' : 'CONTINUE'),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : details.onStepCancel,
                          child: Text('BACK'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Personal Info
              Step(
                title: Text('Personal Information'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Phone number is required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Age is required';
                        if (int.tryParse(val) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              
              // Step 2: Security
              Step(
                title: Text('Security'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password is required';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please confirm your password';
                        if (val != passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              
              // Step 3: Emergency Contact
              Step(
                title: Text('Emergency Contact'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: emergencyNameController,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Emergency contact name is required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Emergency contact phone is required' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _relation,
                      decoration: InputDecoration(
                        labelText: 'Relation',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      items: [
                        "Mother", "Father", "Guardian", "Friend", "Sibling", "Other"
                      ].map((relation) {
                        return DropdownMenuItem(value: relation, child: Text(relation));
                      }).toList(),
                      onChanged: (val) => setState(() => _relation = val),
                      validator: (val) => val == null || val.isEmpty ? 'Please select a relation' : null,
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
                state: StepState.indexed,
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
    phoneController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }
}