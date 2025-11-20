import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/views/loginpage.dart';

class Homepage extends StatefulWidget {
  final User user;
  const Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Homepage'),
        backgroundColor: Colors.orange,
        actions: [
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage())
                );
              }, 
              icon: Icon(Icons.login),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${widget.user.userName}!"
            )
          ],
        ),
      ),
      
    );
  }
}