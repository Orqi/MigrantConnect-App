import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class EmergencyContactsPage extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Police', 'number': '100'},
    {'name': 'Fire Brigade', 'number': '101'},
    {'name': 'Ambulance', 'number': '102'},
    {'name': 'Women’s Helpline', 'number': '1091'},
    {'name': 'AASRA (Suicide Prevention)', 'number': '9152987821'},
    {'name': 'Ex-Servicemen Welfare (ECHS)', 'number': '1800111971'},
    {'name': 'Senior Citizen Helpline', 'number': '14567'},
  ];

  void _callNumber(String number) async {
    final Uri url = Uri.parse('tel:$number'); // Opens dialer without calling
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Opens Phone app
    } else {
      debugPrint('Could not open dialer for $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 242, 242),
      appBar: AppBar(
       title: Text(
          'Emergency Contacts',
          
        ),
        backgroundColor: Color.fromARGB(255, 1, 116, 93),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: GestureDetector(
                onTap: () => _callNumber(contact['number']!),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 94, 44, 73),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // ✅ Prevents text overflow
                        child: Text(
                          contact['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis, // ✅ Cuts text if too long
                        ),
                      ),
                      Icon(Icons.phone, color: Color.fromARGB(255, 255, 139, 104)),
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
}