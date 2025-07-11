import 'package:flutter/material.dart';

class MigrantLawPage extends StatelessWidget {
  const MigrantLawPage({super.key});

  final List<String> keyPoints = const [
    'The Act applies to establishments employing 5 or more inter-state migrant workers.',
    'Contractors must obtain a license before recruiting migrant workers.',
    'Migrant workers must be issued passbooks containing details of employment.',
    'Wages must not be less than the minimum wage applicable in the host state.',
    'The Act mandates displacement allowance and journey allowance for workers.',
    'Suitable residential accommodation and medical facilities must be provided.',
    'Violation of provisions can result in imprisonment or fines.',
    'The Act seeks to protect workers from exploitation and ensure fair treatment.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(title: const Text('Inter-State Migrant Workmen Act'),
      backgroundColor: Color(0xFF788DA0)),
      body: ListView.separated(
        
        padding: const EdgeInsets.all(16),
        itemCount: keyPoints.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
            ),
            title: Text(
              keyPoints[index],
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          );
        },
      ),
    );
  }
}
