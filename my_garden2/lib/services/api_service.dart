import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = 'https://garden2-je8f.onrender.com'; // ← your Render URL

  // ── Auth helpers ───────────────────────────────────────────────────────────

  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Gratitude ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getGratitude() async {
    final res = await http.get(
      Uri.parse('$baseUrl/gratitude'),
      headers: await _authHeaders(),
    );
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
    final res = await http.delete(
      Uri.parse('$baseUrl/gratitude/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
  }

  // ── Strengths ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStrengths() async {
    final res = await http.get(
      Uri.parse('$baseUrl/strengths'),
      headers: await _authHeaders(),
    );
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

  // ── Journal ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getJournal() async {
    final res = await http.get(
      Uri.parse('$baseUrl/journal'),
      headers: await _authHeaders(),
    );
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
    final res = await http.delete(
      Uri.parse('$baseUrl/journal/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
  }

  // ── Friends ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFriends() async {
    final res = await http.get(
      Uri.parse('$baseUrl/friends'),
      headers: await _authHeaders(),
    );
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
    final res = await http.delete(
      Uri.parse('$baseUrl/friends/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
  }

  // ── Users (find other app users to message) ────────────────────────────────

  /// Search for a user by email so you can message them.
  /// Requires a GET /users?email=... endpoint on your backend.
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users?email=${Uri.encodeComponent(email)}'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 404) return null;
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  /// [recipientUid] is the Firebase UID of the person you're messaging.
  static Future<List<Map<String, dynamic>>> getMessages(
      String recipientUid) async {
    final res = await http.get(
      Uri.parse('$baseUrl/messages/$recipientUid'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /// Sends a message to [recipientUid].
  /// The backend uses the Authorization token to determine the sender.
  static Future<Map<String, dynamic>> sendMessage(
      String recipientUid, String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'recipient_uid': recipientUid,
        'content': content,
      }),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  // ── Error handling ─────────────────────────────────────────────────────────

  static void _checkStatus(http.Response res) {
    if (res.statusCode == 401) {
      throw ApiException('Not authenticated. Please sign in again.', 401);
    }
    if (res.statusCode == 403) {
      throw ApiException('You don\'t have permission to do that.', 403);
    }
    if (res.statusCode >= 400) {
      throw ApiException(
          'Request failed (${res.statusCode}): ${res.body}', res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';

// class ApiService {
//   static const String baseUrl = 'https://garden2-je8f.onrender.com';

//   static Future<String?> _getToken() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return null;
//   return await user.getIdToken();
// }

// static Future<Map<String, String>> _authHeaders() async {
//   final token = await _getToken();

//   return {
//     'Content-Type': 'application/json',
//     if (token != null) 'Authorization': 'Bearer $token',
//   };
// }

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

//   static Future<void> updateStrengths(List<Map<String, dynamic>> strengths) async {
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

//   static Future<Map<String, dynamic>> addJournal(String title, String content) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/journal'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'title': title, 'content': content}),
//     );
//     // print("Sending request...");
//     // print(res.statusCode);
//     // print(res.body);
//     return jsonDecode(res.body);
//   }

//   static Future<Map<String, dynamic>> updateJournal(String id, String title, String content) async {
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

//   static Future<Map<String, dynamic>> addFriend(Map<String, dynamic> friend) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/friends'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(friend),
//     );
//     print("Sending request...");
//     print(res.statusCode);
//     print(res.body);
//     return jsonDecode(res.body);
//   }

//   static Future<Map<String, dynamic>> updateFriend(String id, Map<String, dynamic> friend) async {
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

//   static Future<List<Map<String, dynamic>>> getMessages(String friendId) async {
//   final res = await http.get(
//     Uri.parse('$baseUrl/messages/$friendId'),
//     headers: await _authHeaders(),
//   );

//   return List<Map<String, dynamic>>.from(jsonDecode(res.body));
// }

//   static Future<Map<String, dynamic>> sendMessage(
//     String friendId,
//     String content,
// ) async {
//   final res = await http.post(
//     Uri.parse('$baseUrl/messages'),
//     headers: await _authHeaders(),
//     body: jsonEncode({
//       'friend_id': friendId,
//       'content': content,
//       'from_me': true,
//     }),
//   );

//   return jsonDecode(res.body);
// }
// }
