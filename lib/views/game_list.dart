import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/views/auth/login_screen.dart';

class GameList extends StatefulWidget {
  const GameList({Key? key}) : super(key: key);

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  void _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken');

    // Navigate back to the login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game List'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Start a new game with a human opponent'),
              onTap: () {
                // Handle option 1
              },
            ),
            ListTile(
              title: Text('Start a new game with an AI opponent'),
              onTap: () {
                // Handle option 2
              },
            ),
            ListTile(
              title: Text('Show completed games'),
              onTap: () {
                // Handle option 3
              },
            ),
            ListTile(
              title: Text('Log out'),
              onTap: _logOut,
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Game List',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
