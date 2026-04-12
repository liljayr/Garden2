// import 'package:flutter/material.dart';
// import 'services/app_theme.dart';
// import 'screens/home_screen.dart';

// void main() {
//   runApp(const MyGardenApp());
// }

// class MyGardenApp extends StatelessWidget {
//   const MyGardenApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Garden',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.theme,
//       home: const HomeScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'services/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyGardenApp());
}

class MyGardenApp extends StatelessWidget {
  const MyGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Garden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AuthGate(),
    );
  }
}

/// Checks login state on launch, shows LoginScreen or HomeScreen accordingly.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<bool> _checkLogin;

  @override
  void initState() {
    super.initState();
    _checkLogin = AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Splash / loading
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
