import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://165.227.117.48'; // Update the base URL

  static Future<String> get _token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionToken') ?? '';
  }

  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getGames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {'Authorization': 'Bearer ${await _token}'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['games']);
    } else {
      throw Exception('Failed to get games: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> startGame(List<String> ships,
      {String? ai}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games'),
      body: jsonEncode({
        'ships': ships,
        if (ai != null) 'ai': ai,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _token}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getGame(int gameId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer ${await _token}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get game: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> playShot(int gameId, String shot) async {
    final response = await http.put(
      Uri.parse('$baseUrl/games/$gameId'),
      body: jsonEncode({'shot': shot}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _token}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to play shot: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> forfeitGame(int gameId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: {'Authorization': 'Bearer ${await _token}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to forfeit game: ${response.body}');
    }
  }
}
