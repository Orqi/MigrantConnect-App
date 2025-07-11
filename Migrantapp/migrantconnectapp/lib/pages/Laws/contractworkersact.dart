import 'package:flutter/material.dart';

class ContractLabourActPage extends StatelessWidget {
  const ContractLabourActPage({super.key});

  final List<String> keyPoints = const [
    'The Act regulates the employment of contract labour in certain establishments.',
    'Applicable to establishments and contractors employing 20 or more contract workers.',
    'Contractors must obtain a license to supply or employ contract labour.',
    'Principal employers must register their establishments under the Act.',
    'Ensures contract workers receive fair wages, canteen facilities, restrooms, and first aid.',
    'The Act prohibits the employment of contract labour in core activities in some cases.',
    'Authorities can abolish contract labour in specific industries where deemed exploitative.',
    'Violation of the Act may lead to penalties, license cancellation, or imprisonment.',
  ];

  final String summary =
      'The Contract Labour (Regulation and Abolition) Act, 1970 seeks to regulate the conditions of service of contract workers and prevent their exploitation. '
      'It ensures that both principal employers and contractors are responsible for worker welfare. '
      'The Act also empowers governments to abolish contract labour where it is being misused, especially in core production areas.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contract Labour Act, 1970')),
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
