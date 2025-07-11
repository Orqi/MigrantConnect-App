import 'package:flutter/material.dart';

class AccomoScreen extends StatefulWidget {
  const AccomoScreen({Key? key}) : super(key: key);

  @override
  State<AccomoScreen> createState() => _AccommoScreenState();
}

class _AccommoScreenState extends State<AccomoScreen> {
  // Define the color palette based on your theme
  static const Color primaryColor = Color(0xFF133764); // #133764
  static const Color accentColor = Color(0xFFF2B6B3); // #F2B6B3
  static const Color cardBackgroundColor = Color(0xFFFECBCC); // #FECBCC
  static const Color textColorPrimary = Color(0xFF0D3466); // #0D3466
  static const Color textColorSecondary = Color(0xFF788DA0); // #788DA0

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accommodation Services",
          style: TextStyle(color: accentColor), // Text color for app bar title
        ),
        backgroundColor: primaryColor, // App bar background color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCard(
            title: "Government Shelter Homes",
            description: "Find nearby shelter homes operated by the government.",
            icon: Icons.home,
            onTap: () {
              // Navigate or show more info
            },
          ),
          _buildCard(
            title: "Emergency Accommodation",
            description: "Quick access to emergency shelters during crises.",
            icon: Icons.warning,
            onTap: () {
              // Navigate or show more info
            },
          ),
          _buildCard(
            title: "Private Affordable Hostels",
            description: "Low-cost hostels with verified facilities.",
            icon: Icons.hotel,
            onTap: () {
              // Navigate or show more info
            },
          ),
          _buildCard(
            title: "NGO-supported Homes",
            description: "Homes run by NGOs offering support and food.",
            icon: Icons.volunteer_activism,
            onTap: () {
              // Navigate or show more info
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardBackgroundColor, // Card background color
      child: ListTile(
        leading: Icon(icon, size: 40, color: textColorPrimary), // Icon color
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textColorPrimary, // Title text color
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: textColorSecondary), // Subtitle text color
        ),
        onTap: onTap,
      ),
    );
  }
}