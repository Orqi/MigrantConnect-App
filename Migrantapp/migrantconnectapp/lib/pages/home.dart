import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/main.dart'; // Import main.dart to access MyApp
import 'package:migrantconnectapp/pages/emergencycontacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:migrantconnectapp/map.dart'; // Import the MapPage
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map for the preview
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng
// No longer need to import 'jobmarket.dart' if navigating by named route directly
// import 'package:migrantconnectapp/jobmarket.dart'; // This import can be removed if not directly instantiating JobMarketPage
import 'package:migrantconnectapp/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:migrantconnectapp/pages/Laws/Lawsandschemes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isLoggedIn = await magic.user.isLoggedIn();
      if (isLoggedIn) {
        final userMetadata = await magic.user.getInfo();
        setState(() {
          _userEmail = userMetadata.email;
        });
      } else {
        // If not logged in, navigate to login page
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      // Print error for debugging
      print('Error loading user email for home screen: $e');
      if (mounted) {
        // Show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
        // Navigate to login page on error
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Perform Magic SDK logout
      await magic.user.logout();

      // Remove user email from shared preferences if it exists
      final prefs = await SharedPreferences.getInstance();
      if (_userEmail != null) {
        await prefs.remove(_userEmail!);
      }
      setState(() {
        _userEmail = null; // Clear user email state
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      // Navigate to login page after logout
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
      print('Logout error: $e'); // Print error for debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Language switch dialog logic
  void _showLanguagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage), // Use localized string
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocalizations.supportedLocales.map((locale) {
              String languageName;
              switch (locale.languageCode) {
                case 'en':
                  languageName = 'English';
                  break;
                case 'hi':
                  languageName = 'हिंदी';
                  break;
                default:
                  languageName = locale.languageCode;
              }
              return ListTile(
                title: Text(languageName),
                onTap: () {
                  // Set the new locale using the static method from MyApp
                  MyApp.of(context)?.setLocale(locale);
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.welcomeMessage), // Use localized title
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        actions: [
          // Language Switch Icon
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguagePickerDialog, // Call the dialog function
            tooltip: appLocalizations.changeLanguage, // Localized tooltip
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              // Assuming 'migrant.jpg' is in your assets
              child: Image.asset('migrant.jpg'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(color: Colors.tealAccent, height: 20),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(appLocalizations.profile), // Localized
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(appLocalizations.help), // Localized
              onTap: () {
                // TODO: Implement help page navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help page not yet implemented.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(appLocalizations.findJobs), // Localized
              onTap: () {
                // *** IMPORTANT CHANGE HERE ***
                // Navigate using the named route defined in main.dart
                Navigator.pushNamed(context, '/job_market_page');
              },
            ),
            ListTile(
              leading: const Icon(Icons.house),
              title: Text(appLocalizations.findAccommodation), // Localized
              onTap: () {
                // TODO: Implement find accommodation page navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Accommodation page not yet implemented.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(appLocalizations.emergencyContacts), // Localized
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmergencyContactsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Laws and Schemes'), // Corrected typo
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LawsandschemesPage()));
              },
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: Text(appLocalizations.logout), // Localized
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 5,
                  shadowColor: Colors.redAccent.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade50, Colors.teal.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      },
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(10.0, 76.0),
                              initialZoom: 6.5,
                              interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'com.migrantconnectapp',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: const LatLng(10.1, 76.1),
                                    width: 30,
                                    height: 30,
                                    child: const Icon(Icons.location_pin, color: Colors.red, size: 30),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appLocalizations.viewMap, // Localized
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 3.0,
                                          color: Colors.black54,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}