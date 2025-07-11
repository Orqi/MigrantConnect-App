import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/login.dart';
import 'package:migrantconnectapp/home.dart';
import 'package:migrantconnectapp/profile.dart';


final magic = Magic("pk_live_845610B169B276D7");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Magic.instance = magic;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    magic.user.isLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
       
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.pushReplacementNamed('/home');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.pushReplacementNamed('/login');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Login Counterpart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => _buildAuthSwitcher(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            Magic.instance.relayer,
          ],
        );
      },
    );
  }

  Widget _buildAuthSwitcher() {
    return FutureBuilder<bool>(
      future: magic.user.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}