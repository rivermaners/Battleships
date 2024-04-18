import 'package:flutter/material.dart';
import 'package:battleships/views/auth/login_screen.dart';
import 'package:battleships/views/auth/registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      initialRoute: '/', // Specify the initial route
      routes: {
        '/': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(), // Add the home route
      },
    );
  }
}
