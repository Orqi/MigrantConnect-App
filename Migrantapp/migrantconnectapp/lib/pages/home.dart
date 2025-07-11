import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/main.dart';
import 'package:migrantconnectapp/pages/emergencycontacts.dart';
import 'package:migrantconnectapp/pages/migrantlaw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:migrantconnectapp/map.dart'; // Import the MapPage
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map for the preview
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng

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
                // TODO: Implement find jobs page navigation
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
                        builder: (context) => EmergencyContactsPage()));
              },
            ),
            
            Spacer(), // Use Spacer to push the logout button to the bottom
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
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, ${_userEmail ?? 'User'}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> MigrantLawPage() ));
                    }, 
                    label: Text('Migrant Law'),
                    )
                  // Removed the ElevatedButton.icon for 'View Profile' from here
                  // The logout button is now in the drawer
                ],
              ),
      ),
    );
  }
}
