import 'package:flutter/material.dart';
import 'package:pos_mobile/service/auth-service.dart';
import 'package:pos_mobile/service/theme-changer.dart';
import 'package:pos_mobile/view/home-page.dart';
import 'package:pos_mobile/view/sign-in-page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      defaultBrightness: Brightness.dark,
      builder: (context, brightness) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pos App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: brightness
            ),
          home: const StartupGate(),
        );
    });
}
}

/// Decides whether to land on the login screen or the home screen based on
/// whether a refresh token is already stored, so a returning user isn't
/// forced to log in again every launch.
class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == true ? const HomePage() : const LoginPage();
      },
    );
  }
}