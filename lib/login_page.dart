import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup_page.dart'; 
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  void loginUser(BuildContext context) async {
    var response = await http.post(
      Uri.parse("http://192.168.229.73/login.php"),
      body: {
        "phone": phoneController.text,
        "password": passwordController.text,
      },
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (data["status"] == "invalid_password") {
      showDialog(context: context, builder: (_) => AlertDialog(content: Text("Invalid password")));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage(phone: phoneController.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            ElevatedButton(onPressed: () => loginUser(context), child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
