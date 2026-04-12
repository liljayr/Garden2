// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'auth_service.dart'; // ← replaces firebase_auth import

// class ApiService {
//   static const String baseUrl = 'https://garden2-je8f.onrender.com';

//   static Future<Map<String, String>> _authHeaders() async {
//     final token = await AuthService.getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ── Gratitude ──────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> getGratitude() async {
//     final res = await http.get(Uri.parse('$baseUrl/gratitude'));
//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }

//   static Future<Map<String, dynamic>> addGratitude(String text) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/gratitude'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'text': text}),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<void> deleteGratitude(String id) async {
//     await http.delete(Uri.parse('$baseUrl/gratitude/$id'));
//   }

//   // ── Strengths ──────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> getStrengths() async {
//     final res = await http.get(Uri.parse('$baseUrl/strengths'));
//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }

//   static Future<void> updateStrengths(
//       List<Map<String, dynamic>> strengths) async {
//     await http.put(
//       Uri.parse('$baseUrl/strengths'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(strengths),
//     );
//   }

//   static Future<Map<String, dynamic>> addStrength(String name) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/strengths'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name, 'selected': true}),
//     );
//     return jsonDecode(res.body);
//   }

//   // ── Journal ────────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> getJournal() async {
//     final res = await http.get(Uri.parse('$baseUrl/journal'));
//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }

//   static Future<Map<String, dynamic>> addJournal(
//       String title, String content) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/journal'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'title': title, 'content': content}),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<Map<String, dynamic>> updateJournal(
//       String id, String title, String content) async {
//     final res = await http.put(
//       Uri.parse('$baseUrl/journal/$id'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'title': title, 'content': content}),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<void> deleteJournal(String id) async {
//     await http.delete(Uri.parse('$baseUrl/journal/$id'));
//   }

//   // ── Friends ────────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> getFriends() async {
//     final res = await http.get(Uri.parse('$baseUrl/friends'));
//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }

//   static Future<Map<String, dynamic>> addFriend(
//       Map<String, dynamic> friend) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/friends'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(friend),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<Map<String, dynamic>> updateFriend(
//       String id, Map<String, dynamic> friend) async {
//     final res = await http.put(
//       Uri.parse('$baseUrl/friends/$id'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(friend),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<void> deleteFriend(String id) async {
//     await http.delete(Uri.parse('$baseUrl/friends/$id'));
//   }

//   // ── Messages ───────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> getMessages(
//       String friendId) async {
//     final res = await http.get(
//       Uri.parse('$baseUrl/messages/$friendId'),
//       headers: await _authHeaders(),
//     );
//     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
//   }

//   static Future<Map<String, dynamic>> sendMessage(
//       String friendId, String content) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/messages'),
//       headers: await _authHeaders(),
//       body: jsonEncode({
//         'friend_id': friendId,
//         'content': content,
//         'from_me': true,
//       }),
//     );
//     return jsonDecode(res.body);
//   }
// }


// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// // class ApiService {
// //   static const String baseUrl = 'https://garden2-je8f.onrender.com';

// //   // ── Gratitude ──────────────────────────────────────────

// //   static Future<List<Map<String, dynamic>>> getGratitude() async {
// //     final res = await http.get(Uri.parse('$baseUrl/gratitude'));
// //     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// //   }

// //   static Future<Map<String, dynamic>> addGratitude(String text) async {
// //     final res = await http.post(
// //       Uri.parse('$baseUrl/gratitude'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'text': text}),
// //     );
// //     return jsonDecode(res.body);
// //   }

// //   static Future<void> deleteGratitude(String id) async {
// //     await http.delete(Uri.parse('$baseUrl/gratitude/$id'));
// //   }

// //   // ── Strengths ──────────────────────────────────────────

// //   static Future<List<Map<String, dynamic>>> getStrengths() async {
// //     final res = await http.get(Uri.parse('$baseUrl/strengths'));
// //     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// //   }

// //   static Future<void> updateStrengths(List<Map<String, dynamic>> strengths) async {
// //     await http.put(
// //       Uri.parse('$baseUrl/strengths'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(strengths),
// //     );
// //   }

// //   static Future<Map<String, dynamic>> addStrength(String name) async {
// //     final res = await http.post(
// //       Uri.parse('$baseUrl/strengths'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'name': name, 'selected': true}),
// //     );
// //     return jsonDecode(res.body);
// //   }

// //   // ── Journal ────────────────────────────────────────────

// //   static Future<List<Map<String, dynamic>>> getJournal() async {
// //     final res = await http.get(Uri.parse('$baseUrl/journal'));
// //     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// //   }

// //   static Future<Map<String, dynamic>> addJournal(String title, String content) async {
// //     final res = await http.post(
// //       Uri.parse('$baseUrl/journal'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'title': title, 'content': content}),
// //     );
// //     // print("Sending request...");
// //     // print(res.statusCode);
// //     // print(res.body);
// //     return jsonDecode(res.body);
// //   }

// //   static Future<Map<String, dynamic>> updateJournal(String id, String title, String content) async {
// //     final res = await http.put(
// //       Uri.parse('$baseUrl/journal/$id'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'title': title, 'content': content}),
// //     );
// //     return jsonDecode(res.body);
// //   }

// //   static Future<void> deleteJournal(String id) async {
// //     await http.delete(Uri.parse('$baseUrl/journal/$id'));
// //   }

// //   // ── Friends ────────────────────────────────────────────

// //   static Future<List<Map<String, dynamic>>> getFriends() async {
// //     final res = await http.get(Uri.parse('$baseUrl/friends'));
// //     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// //   }

// //   static Future<Map<String, dynamic>> addFriend(Map<String, dynamic> friend) async {
// //     final res = await http.post(
// //       Uri.parse('$baseUrl/friends'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(friend),
// //     );
// //     return jsonDecode(res.body);
// //   }

// //   static Future<Map<String, dynamic>> updateFriend(String id, Map<String, dynamic> friend) async {
// //     final res = await http.put(
// //       Uri.parse('$baseUrl/friends/$id'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(friend),
// //     );
// //     return jsonDecode(res.body);
// //   }

// //   static Future<void> deleteFriend(String id) async {
// //     await http.delete(Uri.parse('$baseUrl/friends/$id'));
// //   }

// //   // ── Messages ───────────────────────────────────────────

// //   static Future<List<Map<String, dynamic>>> getMessages(String friendId) async {
// //     final res = await http.get(Uri.parse('$baseUrl/messages/$friendId'));
// //     return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// //   }

// //   static Future<Map<String, dynamic>> sendMessage(String friendId, String content) async {
// //     final res = await http.post(
// //       Uri.parse('$baseUrl/messages'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'friend_id': friendId, 'content': content, 'from_me': true}),
// //     );
// //     return jsonDecode(res.body);
// //   }
// // }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://garden2-je8f.onrender.com'; // ← your Render URL

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode == 401) throw Exception('Not authenticated');
    if (res.statusCode == 404) {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Not found');
    }
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Request failed');
    }
  }

  // ── Users ──────────────────────────────────────────────

  /// Returns true if username exists, false if not found, throws on other errors.
  static Future<bool> userExists(String username) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/search/$username'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 404) return false;
    if (res.statusCode == 200) return true;
    throw Exception('Search failed');
  }

  // ── Gratitude ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getGratitude() async {
    final res = await http.get(Uri.parse('$baseUrl/gratitude'),
        headers: await _authHeaders());
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> addGratitude(String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/gratitude'),
      headers: await _authHeaders(),
      body: jsonEncode({'text': text}),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<void> deleteGratitude(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/gratitude/$id'),
        headers: await _authHeaders());
    _checkStatus(res);
  }

  // ── Strengths ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStrengths() async {
    final res = await http.get(Uri.parse('$baseUrl/strengths'),
        headers: await _authHeaders());
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<void> updateStrengths(
      List<Map<String, dynamic>> strengths) async {
    final res = await http.put(
      Uri.parse('$baseUrl/strengths'),
      headers: await _authHeaders(),
      body: jsonEncode(strengths),
    );
    _checkStatus(res);
  }

  static Future<Map<String, dynamic>> addStrength(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/strengths'),
      headers: await _authHeaders(),
      body: jsonEncode({'name': name, 'selected': true}),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  // ── Journal ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getJournal() async {
    final res = await http.get(Uri.parse('$baseUrl/journal'),
        headers: await _authHeaders());
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> addJournal(
      String title, String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/journal'),
      headers: await _authHeaders(),
      body: jsonEncode({'title': title, 'content': content}),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateJournal(
      String id, String title, String content) async {
    final res = await http.put(
      Uri.parse('$baseUrl/journal/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({'title': title, 'content': content}),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<void> deleteJournal(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/journal/$id'),
        headers: await _authHeaders());
    _checkStatus(res);
  }

  // ── Friends ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFriends() async {
    final res = await http.get(Uri.parse('$baseUrl/friends'),
        headers: await _authHeaders());
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> addFriend(
      Map<String, dynamic> friend) async {
    final res = await http.post(
      Uri.parse('$baseUrl/friends'),
      headers: await _authHeaders(),
      body: jsonEncode(friend),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateFriend(
      String id, Map<String, dynamic> friend) async {
    final res = await http.put(
      Uri.parse('$baseUrl/friends/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(friend),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  static Future<void> deleteFriend(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/friends/$id'),
        headers: await _authHeaders());
    _checkStatus(res);
  }

  // ── Messages ───────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMessages(
      String recipientUsername) async {
    final res = await http.get(
      Uri.parse('$baseUrl/messages/$recipientUsername'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> sendMessage(
      String recipientUsername, String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'recipient_username': recipientUsername,
        'content': content,
      }),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }
}