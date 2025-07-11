// lib/pages/emergencycontacts.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:migrantconnectapp/l10n/app_localizations.dart'; // Import localization

class EmergencyContactsPage extends StatelessWidget {
  // Define contacts using keys that will be localized
  // The 'number' remains constant as it's a phone number.
  final List<Map<String, String>> contacts = [
    {'nameKey': 'contactPolice', 'number': '100'},
    {'nameKey': 'contactFireBrigade', 'number': '101'},
    {'nameKey': 'contactAmbulance', 'number': '102'},
    {'nameKey': 'contactWomensHelpline', 'number': '1091'},
    {'nameKey': 'contactAasra', 'number': '9152987821'}, // Ensure this is the correct number
    {'nameKey': 'contactExServicemenWelfare', 'number': '1800111971'},
    {'nameKey': 'contactSeniorCitizenHelpline', 'number': '14567'},
  ];

  // Define the updated color palette for a better look
  static const Color primaryDarkBlue = Color(0xFF133764); // #133764
  static const Color secondaryDarkBlue = Color(0xFF0D3466); // #0D3466
  static const Color lightPeach = Color(0xFFF2B6B3); // #F2B6B3
  static const Color lightestPeach = Color(0xFFFECBCC); // #FECBCC
  static const Color greyishBlue = Color(0xFF788DA0); // #788DA0

  void _callNumber(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not open dialer for $number');
      // Optionally, show a SnackBar or AlertDialog to the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not open dialer.')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; // Get localized strings

    return Scaffold(
      backgroundColor: Colors.white, // White background for the scaffold
      appBar: AppBar(
        title: Text(
          appLocalizations.emergencyContacts, // Localize the AppBar title
          style: const TextStyle(
            color: lightPeach, // AppBar title color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryDarkBlue, // AppBar background color
        iconTheme: const IconThemeData(color: lightPeach), // Set back button color if present
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            // Dynamically get the localized name using the 'nameKey'
            final String localizedContactName = _getLocalizedContactName(appLocalizations, contact['nameKey']!);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased vertical padding
              child: GestureDetector(
                onTap: () => _callNumber(contact['number']!),
                child: Container(
                  padding: const EdgeInsets.all(18), // Slightly more padding inside cards
                  decoration: BoxDecoration(
                    color: lightestPeach, // Card background color - softer and more inviting
                    borderRadius: BorderRadius.circular(15), // Slightly more rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Subtle shadow
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localizedContactName, // Use the localized name here
                          style: const TextStyle(
                            fontSize: 19, // Slightly larger font for name
                            fontWeight: FontWeight.bold,
                            color: secondaryDarkBlue, // Text color for contact name - dark blue
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.phone,
                        color: primaryDarkBlue, // Phone icon color - dark blue for good contrast
                        size: 26, // Slightly larger icon
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get localized contact names
  String _getLocalizedContactName(AppLocalizations appLocalizations, String nameKey) {
    switch (nameKey) {
      case 'contactPolice':
        return appLocalizations.contactPolice;
      case 'contactFireBrigade':
        return appLocalizations.contactFireBrigade;
      case 'contactAmbulance':
        return appLocalizations.contactAmbulance;
      case 'contactWomensHelpline':
        return appLocalizations.contactWomensHelpline;
      case 'contactAasra':
        return appLocalizations.contactAasra;
      case 'contactExServicemenWelfare':
        return appLocalizations.contactExServicemenWelfare;
      case 'contactSeniorCitizenHelpline':
        return appLocalizations.contactSeniorCitizenHelpline;
      default:
        return nameKey; // Fallback to key if no translation found
    }
  }
}