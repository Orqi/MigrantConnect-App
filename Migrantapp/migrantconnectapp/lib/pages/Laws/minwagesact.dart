import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class MinimumWagesActPage extends StatefulWidget {
  final String languageCode;
  const MinimumWagesActPage({super.key, required this.languageCode});

  @override
  State<MinimumWagesActPage> createState() => _MinimumWagesActPageState();
}

class _MinimumWagesActPageState extends State<MinimumWagesActPage> {
  final translator = GoogleTranslator();

  List<String> keyPoints = [
    'The Act mandates minimum wage payment to workers in scheduled employment sectors.',
    'Both central and state governments fix and revise minimum wages periodically.',
    'Applicable to casual, contract, daily wage, and migrant workers.',
    'Minimum wages vary by state, skill level (unskilled/skilled), and type of work.',
    'Wages must be paid in cash, not kind, unless authorized by government notification.',
    'Timely wage payment is mandatory — delays can attract penalties.',
    'The Act also mandates rest days, overtime wages, and standard working hours.',
    'Non-payment or underpayment of wages is punishable with fines or imprisonment.',
  ];

  String summary =
      'The Minimum Wages Act ensures that no worker — especially vulnerable groups like inter-state migrants and casual labourers — is paid less than what is legally mandated by the government. '
      'It provides state-wise wage slabs for different job roles and protects against wage delays and exploitation.';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _translateContentIfNeeded();
  }

  Future<void> _translateContentIfNeeded() async {
    if (widget.languageCode == 'en') {
      setState(() => isLoading = false);
      return;
    }

    final translatedPoints = await Future.wait(
      keyPoints.map((point) => translator.translate(point, to: widget.languageCode)),
    );

    final translatedSummary =
        await translator.translate(summary, to: widget.languageCode);

    setState(() {
      keyPoints = translatedPoints.map((t) => t.text).toList();
      summary = translatedSummary.text;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimum Wages Act, 1948'),
        backgroundColor: const Color(0xFF788DA0),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.black)),
                      ),
                      title: Text(point,
                          style: const TextStyle(fontSize: 16, height: 1.4)),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                const Text(
                  'Summary:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(summary, style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
    );
  }
}
