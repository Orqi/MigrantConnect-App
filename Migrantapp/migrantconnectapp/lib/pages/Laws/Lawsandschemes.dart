import 'package:flutter/material.dart';
import 'package:migrantconnectapp/pages/Laws/eshramportal.dart';
import 'package:migrantconnectapp/pages/Laws/onorc.dart';
import 'package:migrantconnectapp/pages/Laws/pmgky.dart';
import 'package:migrantconnectapp/pages/Laws/statewelfare.dart';
import 'package:translator/translator.dart';
import 'package:migrantconnectapp/pages/Laws/contractworkersact.dart';
import 'package:migrantconnectapp/pages/Laws/migrantlaw.dart';
import 'package:migrantconnectapp/pages/Laws/minwagesact.dart';
import 'package:migrantconnectapp/pages/Laws/unorganisedact.dart';

class LawsandschemesPage extends StatefulWidget {
  const LawsandschemesPage({super.key});

  @override
  State<LawsandschemesPage> createState() => _LawsandschemesPageState();
}

class _LawsandschemesPageState extends State<LawsandschemesPage> {
  final translator = GoogleTranslator();
  String languageCode = 'en';

  // Laws
  String titleLaw = 'Laws';
  String migrant = 'Inter-State Migrant Workmen Act';
  String wages = 'Minimum Wages Act';
  String unorganised = 'Unorganised Workers\' Social Security Act';
  String contract = 'Contract Labour Act';

  // Schemes
  String titleSchemes = 'Schemes';
  String eshram = 'eShram Portal';
  String onorc = 'One Nation One Ration Card';
  String pmshram = 'PM Garib Kalyan Yojana';
  String ayushman = 'State Welfare Boards';
  

  // Scheme subtitles
  String subEshram = 'National database for unorganised workers.';
  String subONORC = 'Access subsidised food grain anywhere in India';
  String subPM = 'Financial and food support for poor and migrants';
  String subSWB = 'Kerala, TN & Odisha provide housing, health, pensions';

  @override
  void initState() {
    super.initState();
    _translateAll();
  }

  Future<void> _translateAll() async {
    if (languageCode == 'en') return;

    final translations = await Future.wait([
      // Laws
      translator.translate('Laws', to: languageCode),
      translator.translate('Inter-State Migrant Workmen Act', to: languageCode),
      translator.translate('Minimum Wages Act', to: languageCode),
      translator.translate('Unorganised Workers\' Social Security Act', to: languageCode),
      translator.translate('Contract Labour Act', to: languageCode),

      // Schemes
      translator.translate('Schemes', to: languageCode),
      translator.translate('eShram Portal', to: languageCode),
      translator.translate('One Nation One Ration Card', to: languageCode),
      translator.translate('PM Garib Kalyan Yojana', to: languageCode),
      translator.translate('State Welfare Boards', to: languageCode),

      // Scheme Subtitles
      translator.translate('National database for unorganised workers.', to: languageCode),
      translator.translate('Access subsidised food grain anywhere in India', to: languageCode),
      translator.translate('Financial and food support for poor and migrants', to: languageCode),
      translator.translate('Kerala, TN & Odisha provide housing, health, pensions', to: languageCode),
    ]);

    setState(() {
      // Laws
      titleLaw = translations[0].text;
      migrant = translations[1].text;
      wages = translations[2].text;
      unorganised = translations[3].text;
      contract = translations[4].text;

      // Schemes
      titleSchemes = translations[5].text;
      eshram = translations[6].text;
      pmshram = translations[7].text;
      ayushman = translations[8].text;
      onorc= translations[9].text;

      // Subtitles
      subEshram = translations[10].text;
      subPM = translations[11].text;
      subONORC = translations[12].text;
      subSWB = translations[13].text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 220, 220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3466),
        title: const Text('Laws and Schemes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Language Dropdown
            Row(
              children: [
                const Text('Language: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  focusColor: Color(0xFF788DA0),
                  
                  value: languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                    DropdownMenuItem(value: 'bn', child: Text('Bengali')),
                    DropdownMenuItem(value: 'or', child: Text('Odia')),
                    DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      languageCode = value!;
                    });
                    _translateAll();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Laws Section
            Text(titleLaw, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.gavel, color: Colors.blue),
                title: Text(migrant),
                onTap: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => MigrantLawPage(languageCode: languageCode)
  ));
},
              ),
            ),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.currency_rupee, color: Colors.green),
                title: Text(wages),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MinimumWagesActPage(languageCode: languageCode))),
              ),
            ),
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.orange),
                title: Text(unorganised),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnorganisedWorkersActPage(languageCode: languageCode))),
              ),
            ),
            Card(
              color: Colors.purple.shade50,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.purple),
                title: Text(contract),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContractLabourActPage(languageCode: languageCode))),
              ),
            ),

            const SizedBox(height: 28),

            // Schemes Section
            Text(titleSchemes, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.teal),
                title: Text(eshram),
                subtitle: Text(subEshram),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EShramPortalPage(languageCode: languageCode)));
                },
              ),
            ),
            Card(
              color: Colors.yellow.shade50,
              child: ListTile(
                leading: const Icon(Icons.handshake, color: Colors.amber),
                title: Text(pmshram),
                subtitle: Text(subPM),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PMGKYPage(languageCode: languageCode)));
                },
              ),
            ),
            Card(
              color: Colors.cyan.shade50,
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.cyan),
                title: Text(ayushman),
                subtitle: Text(subSWB),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StateWelfareBoardsPage(languageCode: languageCode)));
                },
              ),
            ),
            Card(
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const Icon(Icons.savings, color: Colors.indigo),
                title: Text(onorc),
                subtitle: Text(subONORC),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ONORCPage(languageCode: languageCode)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
