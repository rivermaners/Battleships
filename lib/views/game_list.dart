import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/services/api_service.dart';
import 'package:battleships/views/auth/login_screen.dart';
import 'package:battleships/views/game_view.dart'; // Import the game view page
import 'package:battleships/views/new_game.dart'; // Import the new game page

class GameList extends StatefulWidget {
  const GameList({Key? key}) : super(key: key);

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  List<Map<String, dynamic>> _games = [];
  bool _showCompletedGames = false;

  @override
  void initState() {
    super.initState();
    _refreshGames();
  }

  void _refreshGames() async {
    try {
      final games = await ApiService.getGames();
      setState(() {
        _games = games;
      });
    } catch (e) {
      print('Failed to refresh games: $e');
    }
  }

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

  void _forfeitGame(int gameId) async {
    try {
      await ApiService.forfeitGame(gameId);
      _refreshGames();
    } catch (e) {
      print('Failed to forfeit game: $e');
    }
  }

  void _startNewGame({String? ai}) async {
    // Generate initial ship positions
    final ships = ['A1', 'B1', 'C1', 'D1', 'E1'];
    try {
      // Start a new game
      await ApiService.startGame(ships, ai: ai);
      // Refresh the game list
      _refreshGames();
    } catch (e) {
      print('Failed to start game: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game List'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshGames,
          ),
        ],
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
              onTap: () => _startNewGame(),
            ),
            ListTile(
              title: Text('Start a new game with an AI opponent'),
              onTap: () => _startNewGame(ai: 'random'),
            ),
            SwitchListTile(
              title: Text('Show completed games'),
              value: _showCompletedGames,
              onChanged: (bool value) {
                setState(() {
                  _showCompletedGames = value;
                });
              },
            ),
            ListTile(
              title: Text('Log out'),
              onTap: _logOut,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return ListTile(
            title: Text('Game ${game['id']}'),
            subtitle: Text(
                'Player 1: ${game['player1']}, Player 2: ${game['player2']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameView(gameId: game['id'])),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _forfeitGame(game['id']),
            ),
          );
        },
      ),
    );
  }
}
