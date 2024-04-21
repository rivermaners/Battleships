import 'package:flutter/material.dart';
import 'package:battleships/services/api_service.dart';

class GameView extends StatefulWidget {
  final int gameId;

  const GameView({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  Map<String, dynamic> _game = {};
  bool _isUserTurn = true;

  @override
  void initState() {
    super.initState();
    _refreshGame();
  }

  void _refreshGame() async {
    try {
      final game = await ApiService.getGame(widget.gameId);
      setState(() {
        _game = game;
        _isUserTurn = _game['turn'] ==
            _game[
                'position']; // Adjust this based on your API response structure
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to refresh game: $e')));
    }
  }

  void _playShot(String position) async {
    if (!_isUserTurn) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("It's not your turn")));
      return;
    }
    try {
      final result = await ApiService.playShot(widget.gameId, position);
      if (result.containsKey('won') && result['won']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('You won the game!')));
      }
      _refreshGame(); // Refresh the game state to reflect the changes
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to play shot: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = screenWidth / 5; // Assuming a 5x5 grid

    return Scaffold(
      appBar: AppBar(
        title: Text('Game ${widget.gameId}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshGame,
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        children: List.generate(25, (index) {
          final row = String.fromCharCode(65 + index ~/ 5);
          final col = (index % 5 + 1).toString();
          final position = '$row$col';
          bool isShip = _game['ships']?.contains(position) ?? false;
          bool isWreck = _game['wrecks']?.contains(position) ?? false;
          bool isShot = _game['shots']?.contains(position) ?? false;
          bool isSunk = _game['sunk']?.contains(position) ?? false;

          Color cellColor = Colors.white; // Default color for water
          if (isShip) cellColor = Colors.blue;
          if (isWreck) cellColor = Colors.black;
          if (isShot) cellColor = Colors.grey;
          if (isSunk) cellColor = Colors.red;

          return GestureDetector(
            onTap: () => _playShot(position),
            child: GridTile(
              child: Container(
                height: cellSize,
                width: cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: cellColor,
                ),
                child: Center(
                  child: Text(position),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
