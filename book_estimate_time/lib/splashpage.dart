import 'dart:async';
import 'package:book_estimate_time/homepage.dart';
import 'package:flutter/material.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    Timer( 
      const Duration(seconds: 2),
      () => Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (content) => const HomePage())) 
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/images/logo.png'),),
    );
  }
}