import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://165.227.117.48'; // Consider updating to HTTPS for security

  // Helper method to retrieve the current session token from SharedPreferences
  static Future<String> get _token async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionToken') ?? '';
  }

  // Register a new user with username and password
  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionToken', data['access_token']);
      return true;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Log in an existing user with username and password
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionToken', data['access_token']);
      return true;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<List<dynamic>> getGames({bool showCompleted = false}) async {
    final token = await _token;
    // Adjust URL based on whether completed games are to be fetched.
    final String url =
        showCompleted ? '$baseUrl/games?status=1&status=2' : '$baseUrl/games';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['games'];
    } else {
      throw Exception('Failed to get games: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getGame(int gameId) async {
    final token = await _token;
    final response = await http.get(Uri.parse('$baseUrl/games/$gameId'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(
          response.body); // Ensure this contains all the new data fields
    } else {
      throw Exception('Failed to get game details: ${response.body}');
    }
  }

  // Start a new game with a list of ship positions
  static Future<Map<String, dynamic>> startNewGame(List<String> ships,
      {String ai = ''}) async {
    final token = await _token;
    final response = await http.post(Uri.parse('$baseUrl/games'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'ships': ships, if (ai.isNotEmpty) 'ai': ai}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start new game: ${response.body}');
    }
  }

  // Play a shot in a specific game
  static Future<Map<String, dynamic>> playShot(int gameId, String shot) async {
    final token = await _token;
    final response = await http.put(Uri.parse('$baseUrl/games/$gameId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'shot': shot}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to play shot: ${response.body}');
    }
  }

  // Forfeit a game by its ID
  static Future<String> forfeitGame(int gameId) async {
    final token = await _token;
    final response = await http.delete(Uri.parse('$baseUrl/games/$gameId'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    } else {
      throw Exception('Failed to forfeit game: ${response.body}');
    }
  }
}
