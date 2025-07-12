import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:migrantconnectapp/main.dart';
import 'package:migrantconnectapp/pages/emergencycontacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:migrantconnectapp/map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:migrantconnectapp/l10n/app_localizations.dart';
import 'package:migrantconnectapp/pages/Laws/Lawsandschemes.dart';
import 'package:migrantconnectapp/voice_assistant.dart'; // Import the VoiceAssistant
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

// --- Custom Color Definitions ---
const Color kcPrimary = Color(0xFF0D3466); // Dark Blue
const Color kcSecondary = Color(0xFF133764); // Slightly lighter dark blue
const Color kcAccentLight = Color(0xFF788DA0); // Greyish blue
const Color kcCardLight = Color(0xFFFECBCC); // Light pink/peach for card backgrounds
const Color kcCardLighter = Color(0xFFF2B6B3); // Slightly darker pink for gradients
const Color kcWhite = Colors.white;
const Color kcCoralPink = Color(0xFFF78E8C); // Retain if needed elsewhere, but not for this animation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userEmail;
  bool _isLoading = false;
  final VoiceAssistant _voiceAssistant = VoiceAssistant(); // Initialize VoiceAssistant
  String _recognizedText = ''; // To display recognized text
  String _aiResponse = ''; // To display AI's response
  bool _isListening = false; // To manage listening state
  bool _isAITyping = false; // To show loading state for AI response

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _voiceAssistant.initTTS(); // Initialize TTS
    _requestMicPermission(); // Request microphone permission on init
  }

  @override
  void dispose() {
    _voiceAssistant.stopSpeaking(); // Stop speaking if active
    _voiceAssistant.stopListening(); // Stop listening if active
    super.dispose();
  }

  // Method to request microphone permission
  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      print("Mic permission granted");
    } else if (status.isDenied) {
      print("Mic permission denied");
      // Optionally show a dialog to explain why permission is needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied. Voice features may not work.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      print("Mic permission permanently denied. Open app settings.");
      // Optionally direct user to app settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission permanently denied. Please enable it in app settings.'),
            action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
          ),
        );
      }
    }
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
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      print('Error loading user email for home screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
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
      await magic.user.logout();
      final prefs = await SharedPreferences.getInstance();
      if (_userEmail != null) {
        await prefs.remove(_userEmail!);
      }
      setState(() {
        _userEmail = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
      print('Logout error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLanguagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changeLanguage),
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
                  MyApp.of(context)?.setLocale(locale);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _toggleListening() async {
    // Check microphone permission before starting/stopping
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      // If permission is not granted, request it and return if still not granted
      await _requestMicPermission();
      final newMicStatus = await Permission.microphone.status;
      if (!newMicStatus.isGranted) {
        print('Microphone permission not granted, cannot start listening.');
        // Provide visual feedback to the user that permission is required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to use voice assistant.')),
        );
        return; // Exit if permission is still not granted
      }
    }

    if (_isListening) {
      _voiceAssistant.stopListening();
      setState(() {
        _isListening = false;
      });
      // Trigger AI response only if recognized text is not empty after stopping listening
      if (_recognizedText.isNotEmpty && _recognizedText != 'Listening...') {
        _getAndSpeakAIResponse(_recognizedText);
      } else {
        // If nothing was recognized, clear AI response and recognized text
        setState(() {
          _aiResponse = '';
          _recognizedText = '';
        });
        _voiceAssistant.speak("I didn't catch that. Please try again.", "English");
      }
    } else {
      setState(() {
        _recognizedText = 'Listening...'; // Initial state when mic is pressed
        _aiResponse = ''; // Clear previous AI response
        _isListening = true;
        _isAITyping = false; // Reset AI typing state
      });
      final currentLocale = Localizations.localeOf(context);
      final language = currentLocale.languageCode == 'hi' ? 'Hindi' : 'English';
      await _voiceAssistant.startListening(
        (text) {
          // Callback for partial results
          setState(() {
            _recognizedText = text;
          });
        },
        language,
        onFinalResult: (finalText) {
          // Callback for final result (triggered automatically by speech_to_text)
          if (finalText.isNotEmpty) {
            _getAndSpeakAIResponse(finalText);
          } else {
            setState(() {
              _aiResponse = "I didn't hear anything. Please try again.";
              _recognizedText = '';
            });
            _voiceAssistant.speak("I didn't catch that. Please try again.", "English");
          }
          setState(() {
            _isListening = false; // Update local state when VoiceAssistant reports final result
          });
        },
      );
    }
  }

  Future<void> _getAndSpeakAIResponse(String prompt) async {
    if (prompt.isEmpty) {
      _voiceAssistant.speak("Please say something.", "English"); // Default to English for this prompt
      setState(() {
        _aiResponse = "I didn't hear anything. Please try again.";
      });
      return;
    }
    setState(() {
      _isAITyping = true; // Show loading indicator for AI
      _aiResponse = 'AI is thinking...';
    });
    final currentLocale = Localizations.localeOf(context);
    final language = currentLocale.languageCode == 'hi' ? 'Hindi' : 'English';
    final response = await _voiceAssistant.getAIResponse(prompt, language);
    setState(() {
      _aiResponse = response;
      _isAITyping = false; // Hide loading indicator
    });
    _voiceAssistant.speak(response, language);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardHeight = 110;
    final double cardWidth = (screenWidth - (16.0 * 2 + 15)) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.welcomeMessage,
          style: TextStyle(fontFamily: 'Monoton',color: kcWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kcPrimary,
        foregroundColor: kcWhite,
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguagePickerDialog,
            tooltip: appLocalizations.changeLanguage,
            color: kcWhite,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: kcPrimary,
              ),
              child: Center(
                child: Image.asset(
                  'assets/man.png',
                  height: 150,  // Reduce height
                  width: 150,   // Reduce width
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Divider(color: kcAccentLight.withOpacity(0.5), height: 20),
            ),
            ListTile(
              leading: Icon(Icons.person, color: kcSecondary),
              title: Text(appLocalizations.profile, style: TextStyle(color: kcSecondary)),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: kcSecondary),
              title: Text(appLocalizations.help, style: TextStyle(color: kcSecondary)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help page not yet implemented.')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: kcSecondary),
              title: Text(appLocalizations.emergencyContacts, style: TextStyle(color: kcSecondary)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyContactsPage()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: Text(appLocalizations.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: kcWhite,
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
            ? const CircularProgressIndicator(color: kcPrimary)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- Shimmering Gradient Animation ---
                    Container(
                      height: 60, // Increased height for a "fatter" look
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), // Slightly more rounded
                        boxShadow: [
                          BoxShadow(
                            color: kcPrimary.withOpacity(0.3), // Darker shadow
                            blurRadius: 15, // More blur
                            spreadRadius: 2,
                            offset: const Offset(0, 8), // More pronounced shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), // Match outer border radius
                        child: const _ShimmeringGradientAnimation(), // Our custom animation widget
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Voice Assistant UI Feedback
                    if (_isListening || _recognizedText.isNotEmpty || _aiResponse.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 15.0),
                        decoration: BoxDecoration(
                          color: kcPrimary.withOpacity(0.05), // Light background for the box
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: kcPrimary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isListening)
                              Center(
                                child: Text(
                                  _recognizedText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kcPrimary,
                                  ),
                                ),
                              )
                            else if (_recognizedText.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You said:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: kcAccentLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _recognizedText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: kcSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            if (_isAITyping)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Center(
                                  child: CircularProgressIndicator(color: kcPrimary),
                                ),
                              )
                            else if (_aiResponse.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Response:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kcAccentLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _aiResponse,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kcPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    // End Voice Assistant UI Feedback
                    
                    // Map Preview Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kcPrimary.withOpacity(0.8), kcSecondary.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kcSecondary.withOpacity(0.4),
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
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.map_outlined,
                                        color: kcWhite,
                                        size: 45,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        appLocalizations.viewMap,
                                        style: const TextStyle(
                                          color: kcWhite,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 4.0,
                                              color: Colors.black87,
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
                    const SizedBox(height: 25),

                    // Stacked Job and Accommodation Cards with Farmer Image
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // Find Jobs Card
                              _buildFeatureCard(
                                context: context,
                                title: appLocalizations.findJobs,
                                icon: Icons.work,
                                width: cardWidth,
                                height: cardHeight,
                                onTap: () {
                                  Navigator.pushNamed(context, '/job_market_page');
                                },
                              ),
                              const SizedBox(height: 15),
                              // Find Accommodation Card
                              _buildFeatureCard(
                                context: context,
                                title: appLocalizations.findAccommodation,
                                icon: Icons.house,
                                width: cardWidth,
                                height: cardHeight,
                                onTap: () {
                                   Navigator.pushNamed(context, '/accomo');
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Farmer Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/farm.png',
                            width: screenWidth * 0.35,
                            height: cardHeight * 2 + 15,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Laws and Schemes Card
                    _buildFeatureCard(
                      context: context,
                      title: appLocalizations.lawsAndSchemes, // Changed to use localization
                      icon: Icons.article,
                      width: double.infinity,
                      height: cardHeight,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LawsandschemesPage()));
                      },
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: Stack(
        children: [
          // Main Voice Assistant Button - Prominent and centered at the bottom
          Positioned(
            bottom: 16.0, // Place it at the very bottom
            left: 16.0,   // Extend from left
            right: 16.0,  // Extend to right
            child: SizedBox( // Use SizedBox to control width and height
              height: 60.0, // Make it a bit taller
              child: FloatingActionButton.extended(
                onPressed: _toggleListening,
                backgroundColor: _isListening ? Colors.red.shade700 : kcPrimary, // Deeper red when listening
                foregroundColor: kcWhite,
                heroTag: 'voiceAssistantBtn', // Unique tag
                label: Text(
                  _isListening ? 'STOP LISTENING' : 'START VOICE ASSISTANT',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic, size: 28), // Slightly larger icon
                elevation: 10, // More prominent shadow
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), // More rounded corners
              ),
            ),
          ),

          // Translate Button - Positioned above and to the right
          Positioned(
            bottom: 90.0, // Adjust position to be above the main button
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/translate');
              },
              mini: true, // Keep it smaller
              backgroundColor: kcPrimary,
              foregroundColor: kcWhite,
              tooltip: appLocalizations.changeLanguage,
              child: const Icon(Icons.translate),
            ),
          ),

          // Wallet Button - Positioned above and to the left
          Positioned(
            bottom: 90.0, // Adjust position to be above the main button
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/wallet');
              },
              mini: true, // Keep it smaller
              backgroundColor: kcPrimary,
              foregroundColor: kcWhite,
              tooltip: 'Wallet',
              child: const Icon(Icons.wallet),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat, // This aligns the right button
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kcCardLight, kcCardLighter],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kcCardLighter.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: kcSecondary),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kcPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- New StatefulWidget for the Shimmering Gradient Animation ---
class _ShimmeringGradientAnimation extends StatefulWidget {
  const _ShimmeringGradientAnimation({super.key});

  @override
  State<_ShimmeringGradientAnimation> createState() => _ShimmeringGradientAnimationState();
}

class _ShimmeringGradientAnimationState extends State<_ShimmeringGradientAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientPositionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4), // Slightly slower shimmer for elegance
      vsync: this,
    )..repeat();

    _gradientPositionAnimation = Tween<double>(
      begin: -2.0, // Start further off-screen left
      end: 2.0,    // End further off-screen right, for a longer sweep
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientPositionAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Using a richer set of colors from your palette for a deeper shimmer
              colors: [
                kcPrimary, // Deep blue
                kcSecondary.withOpacity(0.9), // Lighter dark blue, almost the highlight
                kcAccentLight.withOpacity(0.7), // The actual shimmering highlight
                kcSecondary.withOpacity(0.9),
                kcPrimary,
              ],
              // Adjusted stops to control the spread and sharpness of the highlight
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              begin: Alignment(_gradientPositionAnimation.value, 0.0),
              end: Alignment(_gradientPositionAnimation.value + 1.0, 0.0), // Wider shimmer band
            ),
          ),
        );
      },
    );
  }
}
