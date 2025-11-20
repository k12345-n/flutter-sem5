import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/my_config.dart';
import 'package:pawpal/views/homepage.dart'; 
import 'package:pawpal/models/user.dart'; 
import 'package:pawpal/views/registerpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late double height, width;
  bool visible = true;
  bool isChecked = false;

  late User user;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

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
      appBar: AppBar(title: Text('Login Page'),),
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      children: [
                        Text('Remember me'),
                        Checkbox(
                          value: isChecked, 
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                              updatepref(isChecked);
                            });
                          }
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        loginDialog();
                      },
                      child: Text('Login'),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage()
                        ),
                      );
                    }, child: Text('Dont have an account? Register here'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
  }
  
  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool('rememberMe');
      if (rememberMe != null && rememberMe) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
        isChecked = true;
        setState(() {});
      }
    });
  }
  
  void loginDialog() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the email and password'),
          backgroundColor: Colors.red,
        )
      );
      return;
    } 

  http.post(
    Uri.parse('${MyConfig.baseUrl}/login_user.php'),
    body: {'email' : email, 'password' : password},
    ).then((response) {
      print('${response.body}');
      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['status'] == 'success') {
          user = User.fromJson(resarray['data'][0]);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successfully'),
              backgroundColor: Colors.green,
            )
          );

          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => Homepage(user: user),
            )
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resarray["message"]),
              backgroundColor: Colors.red,
            )
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login fail: ${response.statusCode}"),
            backgroundColor: Colors.red,
          )
        );
      }
    });
  }
  
  Future<void> updatepref(bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (isChecked){
      if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);
        prefs.setBool('rememberMe', isChecked);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email and password saved'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in your email and password'),
            backgroundColor: Colors.red,
          )
        );
        setState(() {
          isChecked = false;          
        });
      }
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preference Removed'),
          backgroundColor: Colors.red,
        )
      );

      emailController.clear();
      passwordController.clear();
      setState(() {});
    }
  }
}
