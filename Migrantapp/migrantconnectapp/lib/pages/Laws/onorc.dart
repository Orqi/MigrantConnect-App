import 'package:flutter/material.dart';

class ONORCPage extends StatelessWidget {
  const ONORCPage({super.key});

  final List<String> keyPoints = const [
    'Launched by the Department of Food and Public Distribution under the Ministry of Consumer Affairs.',
    'Ensures **portability of ration cards** across all states and UTs in India.',
    'Migrant workers can access subsidised food grains from any fair price shop (FPS) across the country.',
    'Uses Aadhaar authentication to allow inter-state and intra-state ration access.',
    'Covers beneficiaries under the **National Food Security Act (NFSA)**.',
    'Promotes food security and reduces dependency on location-specific ration cards.',
    'More than 80 crore beneficiaries can access benefits anywhere in India.',
    'Integrated with the **ePoS (electronic Point of Sale)** system at fair price shops.',
  ];

  final String summary =
      'The One Nation One Ration Card (ONORC) scheme empowers migrant and mobile populations to access food security benefits anywhere in India. '
      'It eliminates the need to reapply for ration cards in new locations and ensures uninterrupted access to subsidised grains under NFSA.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Nation One Ration Card'),
        backgroundColor: const Color(0xFF0D3466),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Key Highlights:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...keyPoints.asMap().entries.map((entry) {
            int index = entry.key;
            String point = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                ),
                title: Text(point, style: const TextStyle(fontSize: 16, height: 1.4)),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Summary:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
