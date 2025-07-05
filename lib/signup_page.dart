import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  final String phone;
  SignupPage({required this.phone});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final emNameController = TextEditingController();
  final emPhoneController = TextEditingController();

  String relation = 'Mother';

  List<String> relations = ['Mother', 'Father', 'Guardian', 'Sibling', 'Friend', 'Other'];

  void signupUser(BuildContext context) async {
    var response = await http.post(
      Uri.parse("http://192.168.229.73/signup.php"),
      body: {
        "name": nameController.text,
        "phone": phoneController.text,
        "password": passwordController.text,
        "age": ageController.text,
        "em_name": emNameController.text,
        "em_phone": emPhoneController.text,
        "em_relation": relation
      },
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else if (data["status"] == "user_exists") {
      showDialog(context: context, builder: (_) => AlertDialog(content: Text("User already exists")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            TextField(controller: ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Age")),
            TextField(controller: emNameController, decoration: InputDecoration(labelText: "Emergency Contact Name")),
            TextField(controller: emPhoneController, decoration: InputDecoration(labelText: "Emergency Contact Phone")),
            DropdownButton<String>(
              value: relation,
              onChanged: (String? newVal) => setState(() => relation = newVal!),
              items: relations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () => signupUser(context), child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
