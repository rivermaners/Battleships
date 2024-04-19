import 'package:flutter/material.dart';
import 'package:battleships/views/auth/login_screen.dart';
import 'package:battleships/views/auth/registration_screen.dart';
import 'package:battleships/views/game_list.dart'; // Import the game list page
import 'package:battleships/views/game_view.dart'; // Import the game view page
import 'package:battleships/views/new_game.dart'; // Import the new game page

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
        '/game_list': (context) => GameList(), // Add the game list route
        '/game_view': (context) =>
            GameView(gameId: 0), // Add the game view route
        '/new_game': (context) => NewGame(), // Add the new game route
      },
    );
  }
}
