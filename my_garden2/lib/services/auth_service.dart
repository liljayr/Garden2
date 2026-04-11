import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  Future<String?> getToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await user.getIdToken();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}