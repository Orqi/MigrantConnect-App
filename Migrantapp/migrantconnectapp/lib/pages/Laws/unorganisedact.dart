import 'package:flutter/material.dart';

class UnorganisedWorkersActPage extends StatelessWidget {
  const UnorganisedWorkersActPage({super.key});

  final List<String> keyPoints = const [
    'The Act provides for the social security and welfare of unorganised sector workers.',
    'Unorganised workers include home-based workers, street vendors, daily wage workers, and migrant labourers.',
    'Mandates registration of workers through self-declaration and simplified procedures.',
    'Provides access to social welfare schemes like life and disability cover, health insurance, maternity benefits, and old age protection.',
    'Establishes state and national social security boards to recommend and monitor welfare schemes.',
    'Focuses on convergence of existing welfare schemes across departments.',
    'Employers or contractors are not required for a worker to claim benefits — worker-centric approach.',
    'Encourages portability and simplified access to benefits for migrant and informal workers.',
  ];

  final String summary =
      'The Unorganised Workers’ Social Security Act, 2008 aims to ensure that workers in the informal sector — including migrants, daily wagers, and home-based workers — are brought under a social safety net. '
      'It empowers workers through easy registration and links them to various welfare schemes without the need for formal employment status.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text('Unorganised Workers’ Social Security Act'),
      backgroundColor: Color(0xFF788DA0),),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Key Provisions:',
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
                  backgroundColor: Colors.orange.shade100,
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
