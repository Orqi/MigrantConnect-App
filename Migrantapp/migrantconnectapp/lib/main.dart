import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:migrantconnectapp/login.dart';
import 'package:migrantconnectapp/pages/home.dart';
import 'package:migrantconnectapp/pages/profile.dart';
import 'package:migrantconnectapp/map.dart';
import 'package:migrantconnectapp/pages/translate.dart';
import 'package:migrantconnectapp/jobmarket.dart';
import 'package:migrantconnectapp/pages/accomo.dart';
import 'package:migrantconnectapp/wallet.dart';
import 'l10n/app_localizations.dart';
final magic = Magic("pk_live_845610B169B276D7");

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

// ✅ Initialize Supabase
await Supabase.initialize(
url: 'https://gqxgsgxvgutktndosfah.supabase.co',
anonKey:
'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGdzZ3h2Z3V0a3RuZG9zZmFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyNDY4MzQsImV4cCI6MjA2NzgyMjgzNH0.AkR1K1mqrnZpD6Qf13PCZhWR2lc9PwQS2XnW7SaTVRc',
);

Magic.instance = magic;

runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

static _MyAppState? of(BuildContext context) =>
context.findAncestorStateOfType<_MyAppState>();

@override
State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
Locale? _locale;

void setLocale(Locale value) {
setState(() {
_locale = value;
});
}

@override
void initState() {
super.initState();
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
Locale('en'),
Locale('hi'),
],
locale: _locale,

// 🚦 Routing
initialRoute: '/',
routes: {
'/': (context) => _buildAuthSwitcher(),
'/login': (context) => const LoginScreen(),
'/home': (context) => const HomeScreen(),
'/profile': (context) => const ProfileScreen(),
'/map': (context) => const MapPage(),
'/job_market_page': (context) => const JobMarketPage(),
'/landowner': (context) => const LandOwnerPage(),
'/translate': (context) => TranslateScreen(),
'/wallet': (context) => const WalletScreen(),
'/accomo': (context) => const AccomoScreen(),
'/job_details': (context) => JobDetailsPage(
job: ModalRoute.of(context)!.settings.arguments as Job,
),
},

// 🪄 Magic Overlay
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