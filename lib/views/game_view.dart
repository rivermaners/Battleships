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
      });
    } catch (e) {
      print('Failed to refresh game: $e');
    }
  }

  void _playShot(String position) async {
    try {
      await ApiService.playShot(widget.gameId, position);
      _refreshGame();
    } catch (e) {
      print('Failed to play shot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          final row = String.fromCharCode(65 + index ~/ 5);
          final col = (index % 5 + 1).toString();
          final position = '$row$col';
          return GestureDetector(
            onTap: () => _playShot(position),
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: _game['ships'].contains(position)
                      ? Colors.blue
                      : _game['shots'].contains(position)
                          ? Colors.grey
                          : Colors.white,
                ),
                child: Center(
                  child: Text(position),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
