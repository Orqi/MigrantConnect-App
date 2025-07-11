// lib/main.dart (No changes needed here, just confirming it's correct)
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/login.dart';
import 'package:migrantconnectapp/pages/home.dart';
import 'package:migrantconnectapp/pages/profile.dart';
import 'package:migrantconnectapp/map.dart';
import 'package:migrantconnectapp/pages/translate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart'; // 🌐 Your custom localization file
import 'package:migrantconnectapp/jobmarket.dart';
import 'package:migrantconnectapp/pages/accomo.dart'; // <--- Import your jobmarket.dart file

final magic = Magic("pk_live_845610B169B276D7");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase (replace with your actual URL and anonKey)
  await Supabase.initialize(
    url: 'https://gqxgsgxvgutktndosfah.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGdzZ3h2Z3V0a3RuZG9zZmFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyNDY4MzQsImV4cCI6MjA2NzgyMjgzNH0.AkR1K1mqrnZpD6Qf13PCZhWR2lc9PwQS2XnW7SaTVRc',
  );

  Magic.instance = magic;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Static method to easily access and change locale from anywhere
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Locale? _locale; // Make it nullable to indicate no explicit choice yet

  // Method to set the app's locale
  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  void initState() {
    super.initState();
    // 🚀 Auto-redirect based on login status
    magic.user.isLoggedIn().then((isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushReplacementNamed(
          isLoggedIn ? '/home' : '/login',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migrant Connect',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,

      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // 🌐 Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
      ],
      locale: _locale, // <--- Use the state-managed locale here

      // 🚦 Navigation
      initialRoute: '/',
      routes: {
        '/': (context) => _buildAuthSwitcher(),
        '/login': (context) => const LoginScreen(),
        '/accomo':(context)=> const AccomoScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/map': (context) => const MapPage(),
        '/job_market_page': (context) => const JobMarketPage(), // <--- Correctly referencing JobMarketPage
        '/landowner': (context) => const LandOwnerPage(),
        '/translate': (context) => TranslateScreen(),
        '/job_details': (context) => JobDetailsPage(
              job: ModalRoute.of(context)!.settings.arguments as Job,
            ),
      },

      //  Magic relayer
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

  // 🛂 Show loading or switch to screen
  Widget _buildAuthSwitcher() {
    return FutureBuilder<bool>(
      future: magic.user.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return snapshot.data == true
              ? const HomeScreen()
              : const LoginScreen();
        }
      },
    );
  }
}