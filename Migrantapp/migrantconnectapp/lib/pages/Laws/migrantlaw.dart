import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class MigrantLawPage extends StatefulWidget {
  final String languageCode;
  const MigrantLawPage({super.key, required this.languageCode});

  @override
  State<MigrantLawPage> createState() => _MigrantLawPageState();
}

class _MigrantLawPageState extends State<MigrantLawPage> {
  final translator = GoogleTranslator();
  bool isLoading = true;

  List<String> keyPoints = [
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
  void initState() {
    super.initState();
    _translatePointsIfNeeded();
  }

  Future<void> _translatePointsIfNeeded() async {
    if (widget.languageCode == 'en') {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final translatedPoints = await Future.wait(
      keyPoints.map((point) => translator.translate(point, to: widget.languageCode)),
    );

    setState(() {
      keyPoints = translatedPoints.map((t) => t.text).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inter-State Migrant Workmen Act'),
        backgroundColor: const Color(0xFF788DA0),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: keyPoints.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.black),
                    ),
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
