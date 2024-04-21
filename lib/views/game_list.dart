import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/views/auth/login_screen.dart';
import 'package:battleships/services/api_service.dart';
import 'package:battleships/views/new_game.dart';
import 'package:battleships/views/ship_placement_screen.dart';

class GameList extends StatefulWidget {
  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  List<dynamic> games = [];
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken'); // Clear the session token
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void fetchGames() async {
    try {
      List<dynamic> allGames = await ApiService.getGames(showCompleted: false);
      if (showCompleted) {
        List<dynamic> completedGames = allGames.where((game) {
          return game['status'] == 1 || game['status'] == 2;
        }).toList();
        setState(() {
          games = completedGames;
        });
      } else {
        setState(() {
          games = allGames;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching games: $e')));
    }
  }

  Future<void> selectAndStartGameWithAI() async {
    final String? aiType = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose AI opponent'),
        children: <String>['random', 'perfect', 'oneship']
            .map((String ai) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, ai),
                  child: Text(ai),
                ))
            .toList(),
      ),
    );

    if (aiType != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShipPlacementScreen(
                    onPlacementComplete: (List<String> ships) async {
                      try {
                        await ApiService.startNewGame(ships, ai: aiType);
                        fetchGames(); // Refresh the list after starting a new game
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to start game with AI: $e')));
                      }
                    },
                  )));
    }
  }

  Future<void> _confirmForfeit(int gameId) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Forfeit"),
              content:
                  const Text("Are you sure you want to forfeit this game?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        String message = await ApiService.forfeitGame(gameId);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        fetchGames(); // Refresh the game list
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error forfeiting game: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game List'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchGames),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  FutureBuilder<String>(
                    future: getUsername(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text('Logged in as ${snapshot.data}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18));
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_box_rounded),
              title: const Text('New Game'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NewGame()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('New Game (AI)'),
              onTap: () {
                Navigator.pop(context);
                selectAndStartGameWithAI();
              },
            ),
            SwitchListTile(
              title: const Text('Show completed games'),
              value: showCompleted,
              onChanged: (bool value) {
                setState(() {
                  showCompleted = value;
                });
                fetchGames();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pop(context);
                logOut();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          var game = games[index];
          return ListTile(
            title: Text(
                'Game ID: ${game['id']} - ${game['player1']} vs ${game['player2']}'),
            subtitle: Text('Status: ${game['status']}'),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'forfeit') {
                  _confirmForfeit(game['id']);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'forfeit',
                  child: Text('Forfeit Game'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/game_view', arguments: game['id']);
            },
          );
        },
      ),
    );
  }

  Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'No username found';
  }
}
