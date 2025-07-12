import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class EShramPortalPage extends StatefulWidget {
  final String languageCode;
  const EShramPortalPage({super.key, required this.languageCode});

  @override
  State<EShramPortalPage> createState() => _EShramPortalPageState();
}

class _EShramPortalPageState extends State<EShramPortalPage> {
  final translator = GoogleTranslator();
  List<String> translatedPoints = [];
  String translatedSummary = '';
  bool isLoading = true;

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
  void initState() {
    super.initState();
    _translateContent();
  }

  Future<void> _translateContent() async {
    if (widget.languageCode == 'en') {
      translatedPoints = keyPoints;
      translatedSummary = summary;
    } else {
      translatedPoints = await Future.wait(keyPoints.map((point) async {
        final translated = await translator.translate(point, to: widget.languageCode);
        return translated.text;
      }));
      final translated = await translator.translate(summary, to: widget.languageCode);
      translatedSummary = translated.text;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eShram Portal'),
        backgroundColor: const Color(0xFF0D3466),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Key Highlights:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...translatedPoints.asMap().entries.map((entry) {
                  int index = entry.key;
                  String point = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.black)),
                      ),
                      title:
                          Text(point, style: const TextStyle(fontSize: 16, height: 1.4)),
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
                  translatedSummary,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
    );
  }
}
