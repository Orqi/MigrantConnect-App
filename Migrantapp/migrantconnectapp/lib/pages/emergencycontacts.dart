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

  void _callNumber(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not open dialer for $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; // Get localized strings

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 242, 242),
      appBar: AppBar(
       title: Text(
          appLocalizations.emergencyContacts, // Localize the AppBar title
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 116, 93),
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
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: GestureDetector(
                onTap: () => _callNumber(contact['number']!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 94, 44, 73),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localizedContactName, // Use the localized name here
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.phone, color: Color.fromARGB(255, 255, 139, 104)),
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