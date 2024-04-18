import 'package:flutter/material.dart';
import 'package:battleships/helpers/database_helper.dart';
import 'package:battleships/views/home_screen.dart'; // Import the HomeScreen widget

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      // Perform login logic here
      final bool success = await _authenticateUser(username, password);

      if (success) {
        // Navigate to the home screen if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid username and password.';
      });
    }
  }

  Future<bool> _authenticateUser(String username, String password) async {
    // Get user data from local database
    final userData = await DatabaseHelper.getUserData();
    final String? storedUsername = userData['username'];
    final String? storedPassword = userData['password'];

    // Check if the entered username and password match the stored credentials
    if (username == storedUsername && password == storedPassword) {
      // Authentication successful
      return true;
    } else {
      // Authentication failed
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
