import 'package:flutter/material.dart';

class ShipPlacementScreen extends StatefulWidget {
  final Function(List<String>) onPlacementComplete;

  const ShipPlacementScreen({Key? key, required this.onPlacementComplete})
      : super(key: key);

  @override
  _ShipPlacementScreenState createState() => _ShipPlacementScreenState();
}

class _ShipPlacementScreenState extends State<ShipPlacementScreen> {
  List<String> selectedPositions = [];

  void togglePosition(String position) {
    setState(() {
      if (selectedPositions.contains(position)) {
        selectedPositions.remove(position);
      } else if (selectedPositions.length < 5) {
        // Assuming 5 ships
        selectedPositions.add(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Your Ships"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (selectedPositions.length == 5) {
                widget.onPlacementComplete(selectedPositions);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please place exactly 5 ships."),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          final row = String.fromCharCode(65 + index ~/ 5);
          final col = (index % 5 + 1).toString();
          final position = '$row$col';
          bool isSelected = selectedPositions.contains(position);
          return GestureDetector(
            onTap: () => togglePosition(position),
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey),
                ),
                child: Center(
                  child: Text(
                    position,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
