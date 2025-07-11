import 'package:flutter/material.dart';

class EShramPortalPage extends StatelessWidget {
  const EShramPortalPage({super.key});

  final List<String> keyPoints = const [
    'Launched by the Ministry of Labour and Employment in 2021.',
    'Aims to build a national database of unorganised workers (UWs).',
    'Covers construction workers, migrant workers, street vendors, domestic workers, etc.',
    'Provides each worker with a 12-digit Universal Account Number (UAN).',
    'Facilitates delivery of social security benefits and future scheme linkage.',
    'Registration is free and requires Aadhaar, mobile number, and bank account.',
    'Workers can self-register online or through Common Service Centres (CSCs).',
    'Ensures better portability and targeting of welfare schemes for migrant workers.',
  ];

  final String summary =
      'The eShram Portal is India’s first national database for unorganised workers, enabling access to various welfare schemes through a single ID system. '
      'It focuses on social security, mobility, and financial inclusion for millions of informal workers, especially migrants.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eShram Portal'),
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
                  backgroundColor: Colors.teal.shade100,
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
