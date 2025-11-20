import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/my_config.dart';
import 'package:pawpal/views/loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double height, width;
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PawPal Register Page')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/pawpal.png', scale: 1),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => visible = !visible),
                        icon: Icon(Icons.visibility)),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        registerDialog();
                      },
                      child: Text('Register'),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const LoginPage()
                        ),
                      );
                    }, child: Text('Already have an account? Login here'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void registerDialog() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password != confirmPassword) {
      SnackBar snackBar = const SnackBar(
        content: Text('Passwords do not match'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = SnackBar(
        content: Text('Please enter a valid email')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser(email, password, name, phone);
            }, 
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            child: Text('Cancel'),
          ),
        ],
        content: Text('Are you sure you want to register this account?'),
      ),
    );
  }
  
  void registerUser(String email, String password, String name, String phone) {
    http.post(
     Uri.parse('${MyConfig.baseUrl}/register_user.php'),
     body: {'email': email, 'name': name, 'phone': phone, 'password': password},
    ).then((response) {
      print('${response.body}');
      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['status'] == 'success') {
          showMessage('Registration Successful');
          Navigator.pop(context);
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginPage())
          );
        } else {
          showMessage(resarray['message']);
        }
      } else {
        showMessage('Registration fail. Please try again');
      }
    });
  }
  
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
