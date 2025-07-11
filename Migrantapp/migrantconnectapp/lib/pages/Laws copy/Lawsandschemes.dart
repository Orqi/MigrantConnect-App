import 'package:flutter/material.dart';
import 'package:migrantconnectapp/pages/Laws/contractworkersact.dart';
import 'package:migrantconnectapp/pages/Laws/eshramportal.dart';
import 'package:migrantconnectapp/pages/Laws/migrantlaw.dart';
import 'package:migrantconnectapp/pages/Laws/minwagesact.dart';
import 'package:migrantconnectapp/pages/Laws/onorc.dart';
import 'package:migrantconnectapp/pages/Laws/pmgky.dart';
import 'package:migrantconnectapp/pages/Laws/statewelfare.dart';
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
      backgroundColor: const Color.fromARGB(255, 251, 220, 220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3466),
        title: const Text(
          'Laws and Schemes',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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

            const SizedBox(height: 24),
            const Text(
              'Government Schemes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // eShram Portal
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.account_circle_outlined, color: Colors.teal),
                title: const Text('eShram Portal'),
                subtitle: const Text('National database for unorganised workers'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EShramPortalPage()));
                },
              ),
            ),

            // One Nation One Ration Card
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.rice_bowl_outlined, color: Colors.red),
                title: const Text('One Nation One Ration Card'),
                subtitle: const Text('Access subsidised food grain anywhere in India'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ONORCPage()));
                },
              ),
            ),

            // PM Garib Kalyan Yojana
            Card(
              color: Colors.amber.shade50,
              child: ListTile(
                leading: const Icon(Icons.volunteer_activism, color: Colors.amber),
                title: const Text('PM Garib Kalyan Yojana'),
                subtitle: const Text('Financial and food support for poor and migrants'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PMGKYPage()));
                },
              ),
            ),

            // State Welfare Boards
            Card(
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo),
                title: const Text('State Welfare Boards'),
                subtitle: const Text('Kerala, TN & Odisha provide housing, health, pensions'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StateWelfareBoardsPage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
