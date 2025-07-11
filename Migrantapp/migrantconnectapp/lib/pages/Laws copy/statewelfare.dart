import 'package:flutter/material.dart';

class StateWelfareBoardsPage extends StatelessWidget {
  const StateWelfareBoardsPage({super.key});

  final List<String> keyPoints = const [
    'State-level bodies that implement welfare schemes for **migrant and unorganised workers**.',
    'Example states: **Kerala, Tamil Nadu, Odisha, Maharashtra**, etc.',
    'Provide access to **affordable housing, health insurance, pensions, maternity support**, and more.',
    'Offer **scholarships for children** of registered workers.',
    'Support for **accidental death, disability**, and funeral assistance.',
    'Encourage registration of workers through online and offline modes.',
    'Kerala’s **Aawaz Health Insurance Scheme** and **Apna Ghar Housing Scheme** are well-known examples.',
    'Boards are often linked with Labour Departments for scheme disbursal and worker tracking.',
  ];

  final String summary =
      'State Welfare Boards act as a bridge between the government and migrant/unorganised workers by providing tailored benefits like healthcare, housing, education, '
      'and social security. States like Kerala and Tamil Nadu lead with strong implementation and tracking systems.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Welfare Boards'),
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
                  backgroundColor: Colors.indigo.shade100,
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
