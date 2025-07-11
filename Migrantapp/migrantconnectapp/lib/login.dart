import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/main.dart'; // Assuming this is needed for 'magic' instance

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = "";
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  // Define the color palette
  static const Color primaryColor = Color(0xFF133764); // Dark Blue
  static const Color accentColor = Color(0xFFF2B6B3); // Light Salmon/Pink
  static const Color secondaryColor = Color(0xFF788DA0); // Greyish Blue
  static const Color darkAccentColor = Color(0xFF0D3466); // Darker Blue
  static const Color lightBackground = Color(0xFFFECBCC); // Very Light Pink

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_email.isEmpty) {
      _showMessage('Please enter an email address.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await magic.auth.loginWithEmailOTP(email: _email);
      final userMetadata = await magic.user.getInfo();
      if (userMetadata.email != null) {
        _showMessage('Login successful! Check your email for the OTP.');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showMessage('Login failed: User metadata not found.');
      }
    } catch (e) {
      _showMessage('Error during login: $e');
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        backgroundColor: darkAccentColor, // Use a color from the palette
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground, // Set overall background color
      appBar: AppBar(
        title: const Text(
  'Login Here',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: 'Monoton',
  ),
),
        backgroundColor: primaryColor, // Use primary color for app bar
        foregroundColor: Colors.white,
        elevation: 0, // Flat app bar for modern look
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: darkAccentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white, // Card background remains white for contrast
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: primaryColor), // Use primary color
                            const SizedBox(height: 20),
                            Text('Processing your request...',
                                style: TextStyle(fontSize: 18, color: secondaryColor)), // Use secondary color
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Image asset
                            Image.asset(
                              'assets/people.png', // Ensure this path is correct and image is in pubspec.yaml
                              height: 200,
                              width: 500,
                            ),
                            const SizedBox(height: 25),
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor), // Use primary color
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sign in to continue your journey.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: secondaryColor), // Use secondary color
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: _emailController,
                              onChanged: (value) => _email = value.trim(),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'your.email@example.com',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none, // Remove default border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor, width: 2), // Primary color on focus
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: lightBackground, width: 1), // Light border when not focused
                                ),
                                prefixIcon: Icon(Icons.email, color: primaryColor), // Primary color for icon
                                filled: true,
                                fillColor: lightBackground.withOpacity(0.6), // Light background for text field
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              ),
                              style: TextStyle(color: darkAccentColor), // Text color in input
                              cursorColor: primaryColor, // Cursor color
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity, // Make button full width
                              child: ElevatedButton.icon(
                                onPressed: _handleLogin,
                                icon: const Icon(Icons.send, size: 20),
                                label: const Text('Get Magic Link'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor, // Primary color for button
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  elevation: 7,
                                  shadowColor: primaryColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}