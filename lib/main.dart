import 'package:flutter/material.dart';
import 'package:battleships/views/auth/login_screen.dart';
import 'package:battleships/views/auth/registration_screen.dart';
import 'package:battleships/views/game_list.dart';
import 'package:battleships/views/game_view.dart';
import 'package:battleships/views/new_game.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/game_list': (context) => GameList(),
        '/new_game': (context) => NewGame(),
        // Adding the new route for GameView
        '/game_view': (context) =>
            GameView(gameId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}
