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

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  @override
  void dispose() {
    super.dispose();
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
                      title: 'Laws and Schemes',
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
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/translate');
              },
              mini: true, // Makes the button smaller
              backgroundColor: kcPrimary,
              foregroundColor: kcWhite,
              tooltip: appLocalizations.changeLanguage,
              child: const Icon(Icons.translate),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/wallet');
              },
              mini: true, // Makes the button smaller
              backgroundColor: kcPrimary, // Set to kcCoralPink
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