import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class PMGKYPage extends StatefulWidget {
  final String languageCode;
  const PMGKYPage({super.key, required this.languageCode});

  @override
  State<PMGKYPage> createState() => _PMGKYPageState();
}

class _PMGKYPageState extends State<PMGKYPage> {
  final translator = GoogleTranslator();
  bool isLoading = true;
  List<String> translatedPoints = [];
  String translatedSummary = '';

  final List<String> keyPoints = const [
    'Launched in 2020 as part of the COVID-19 relief package for the poor and migrant workers.',
    'Provides free food grains (5 kg rice/wheat + 1 kg pulses) per person per month.',
    'Includes Direct Benefit Transfers (DBT) for Jan Dhan account holders.',
    'Offers Rs. 500/month to women Jan Dhan Yojana accounts for 3 months.',
    'Free gas cylinders under the Ujjwala Yojana scheme.',
    'EPF contributions made by the government for eligible small businesses.',
    'Financial assistance to construction workers through state welfare boards.',
    'Support for migrant labourers who lost jobs or were stranded during lockdown.',
  ];

  final String summary =
      'The Pradhan Mantri Garib Kalyan Yojana (PMGKY) is a financial and welfare package designed to protect vulnerable sections, especially migrant workers, '
      'during economic crises like the COVID-19 pandemic. It ensures access to essential food, fuel, and financial resources across the country.';

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
        title: const Text('PM Garib Kalyan Yojana'),
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
                        backgroundColor: Colors.amber.shade100,
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
