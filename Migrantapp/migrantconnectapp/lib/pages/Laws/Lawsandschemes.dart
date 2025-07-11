import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laws and Schemes'),
        centerTitle: true,
        
      ),
      body:  Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Laws',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),

      // Inter-State Migrant Workmen Act
      Card(
        color: Colors.blue.shade50,
        child: ListTile(
          leading: const Icon(Icons.gavel, color: Colors.blue),
          title: const Text('Inter-State Migrant Workmen Act'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MigrantLawPage()));
          },
        ),
      ),

      // Minimum Wages Act
      Card(
        color: Colors.green.shade50,
        child: ListTile(
          leading: const Icon(Icons.currency_rupee, color: Colors.green),
          title: const Text('Minimum Wages Act'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MinimumWagesActPage()));
          },
        ),
      ),

      // Unorganised Workers’ Social Security Act
      Card(
        color: Colors.orange.shade50,
        child: ListTile(
          leading: const Icon(Icons.verified_user, color: Colors.orange),
          title: const Text('Unorganised Workers\' Social Security Act'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UnorganisedWorkersActPage()));
          },
        ),
      ),

      // Contract Labour Act
      Card(
        color: Colors.purple.shade50,
        child: ListTile(
          leading: const Icon(Icons.assignment, color: Colors.purple),
          title: const Text('Contract Labour Act'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ContractLabourActPage()));
          },
        ),
      ),
    ],
  ),
),

    );
  }
}