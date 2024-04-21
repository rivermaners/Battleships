import 'package:flutter/material.dart';
import 'package:battleships/services/api_service.dart';
import 'package:battleships/views/game_list.dart';

class NewGame extends StatefulWidget {
  const NewGame({Key? key}) : super(key: key);

  @override
  _NewGameState createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  List<String> _ships = [];

  void _toggleShip(String position) {
    setState(() {
      if (_ships.contains(position)) {
        _ships.remove(position);
      } else if (_ships.length < 5) {
        _ships.add(position);
      }
    });
  }

  void _startGame() async {
    if (_ships.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please place exactly 5 ships to start the game.')));
      return;
    }

    try {
      await ApiService.startNewGame(_ships);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameList()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start game: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Game'),
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
            onTap: () => _toggleShip(position),
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: _ships.contains(position) ? Colors.blue : Colors.white,
                ),
                child: Center(
                  child: Text(position),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ships.length == 5 ? _startGame : null,
        backgroundColor:
            _ships.length == 5 ? Theme.of(context).primaryColor : Colors.grey,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
