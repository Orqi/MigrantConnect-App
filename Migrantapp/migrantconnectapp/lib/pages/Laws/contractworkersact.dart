import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class ContractLabourActPage extends StatefulWidget {
  final String languageCode;
  const ContractLabourActPage({super.key, required this.languageCode});

  @override
  State<ContractLabourActPage> createState() => _ContractLabourActPageState();
}

class _ContractLabourActPageState extends State<ContractLabourActPage> {
  final translator = GoogleTranslator();

  List<String> keyPoints = [
    'The Act regulates the employment of contract labour in certain establishments.',
    'Applicable to establishments and contractors employing 20 or more contract workers.',
    'Contractors must obtain a license to supply or employ contract labour.',
    'Principal employers must register their establishments under the Act.',
    'Ensures contract workers receive fair wages, canteen facilities, restrooms, and first aid.',
    'The Act prohibits the employment of contract labour in core activities in some cases.',
    'Authorities can abolish contract labour in specific industries where deemed exploitative.',
    'Violation of the Act may lead to penalties, license cancellation, or imprisonment.',
  ];

  String summary =
      'The Contract Labour (Regulation and Abolition) Act, 1970 seeks to regulate the conditions of service of contract workers and prevent their exploitation. '
      'It ensures that both principal employers and contractors are responsible for worker welfare. '
      'The Act also empowers governments to abolish contract labour where it is being misused, especially in core production areas.';

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
        title: const Text('Contract Labour Act, 1970'),
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
                        backgroundColor: Colors.orange.shade100,
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.black)),
                      ),
                      title: Text(
                        point,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
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
