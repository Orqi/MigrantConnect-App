import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/main.dart';
import 'package:migrantconnectapp/pages/emergencycontacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:migrantconnectapp/map.dart'; // Import the MapPage
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map for the preview
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng
import 'package:migrantconnectapp/jobmarket.dart'; // Import Jobmarket

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          // Use Column to place logout at the bottom
          children: [
            DrawerHeader(
              // Placeholder for app logo/image
              child: Image.asset('migrant.jpg'), // Ensure this asset exists
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(color: Colors.tealAccent, height: 20),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pushNamed('/profile'); // Added navigation to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                // TODO: Implement help page navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Find Jobs'),
              onTap: () {
                // Navigate to Jobmarket
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Jobmarket()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.house),
              title: const Text('Find Accommodation'), // Corrected typo
              onTap: () {
                // TODO: Implement find accommodation page navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Emergency Contacts'),
              onTap: () {
                // Navigate to EmergencyContactsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmergencyContactsPage()),
                );
              },
            ),
            const Spacer(), // Use Spacer to push the logout button to the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                      double.infinity, 50), // Make the button full width
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
            ? const CircularProgressIndicator() // Show loading indicator
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 130, // Set height as requested
                    decoration: BoxDecoration(
                      // Enhanced background with a subtle gradient
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade50, Colors.teal.shade200], // Changed to teal shades
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Increased opacity
                          blurRadius: 15, // Increased blur
                          spreadRadius: 2, // Added spread radius
                          offset: const Offset(0, 8), // Adjusted offset
                        ),
                      ],
                    ),
                    child: InkWell( // InkWell for ripple effect on tap
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Navigate to MapPage when the card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      },
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(10.0, 76.0), // Center of Kerala
                              initialZoom: 6.5, // Zoomed out for a broader view
                              interactionOptions: InteractionOptions(flags: InteractiveFlag.none), // Disable interaction
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'com.migrantconnectapp', // Required for OpenStreetMap
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: const LatLng(10.1, 76.1), // Example marker point
                                    width: 30,
                                    height: 30,
                                    child: const Icon(Icons.location_pin, color: Colors.red, size: 30),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Overlay content to make it more attractive and indicate tap
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined, // A more stylized map icon
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'View Map',
                                    style: TextStyle(
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