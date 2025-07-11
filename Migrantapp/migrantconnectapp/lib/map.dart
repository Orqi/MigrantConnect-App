import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// Enum for categories
enum MapCategory {
  allLocations,
  healthcare,
  governmentSupport,
  sheltersHousing,
  foodSupplies,
  legalDocumentation,
  jobSkillCenters,
  educationChildcare,
  placesOfWorship,
}

// Display names for categories
extension MapCategoryExtension on MapCategory {
  String get displayName {
    switch (this) {
      case MapCategory.allLocations:
        return 'All Locations';
      case MapCategory.healthcare:
        return 'Healthcare';
      case MapCategory.governmentSupport:
        return 'Government Support Centers';
      case MapCategory.sheltersHousing:
        return 'Shelters & Housing';
      case MapCategory.foodSupplies:
        return 'Food & Supplies';
      case MapCategory.legalDocumentation:
        return 'Legal & Documentation Support';
      case MapCategory.jobSkillCenters:
        return 'Job & Skill Centers';
      case MapCategory.educationChildcare:
        return 'Education & Childcare';
      case MapCategory.placesOfWorship:
        return 'Places of Worship / Community';
    }
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapCategory _selectedCategory = MapCategory.allLocations;

  // Define your new colors
  final Color _primaryDarkBlue = const Color(0xFF0D3466); // #0D3466
  final Color _secondaryDarkBlue = const Color(0xFF133764); // #133764
  final Color _mutedBlueGrey = const Color(0xFF788DA0);    // #788DA0
  // The light peach colors are not directly used on these elements
  // to maintain readability and contrast, but are available in the palette.
  // final Color _lightPeach1 = const Color(0xFFFECBCC);
  // final Color _lightPeach2 = const Color(0xFFF2B6B3);


  final List<Map<String, dynamic>> _allLocations = [
    // Static Dummy Data
    {'category': MapCategory.healthcare, 'lat': 9.9816, 'lon': 76.2999, 'name': 'General Hospital Kochi', 'icon': Icons.local_hospital},
    {'category': MapCategory.healthcare, 'lat': 10.00, 'lon': 76.30, 'name': 'PHC Ernakulam', 'icon': Icons.medical_services},
    {'category': MapCategory.healthcare, 'lat': 9.95, 'lon': 76.25, 'name': 'Red Cross Office', 'icon': Icons.emergency},
    {'category': MapCategory.governmentSupport, 'lat': 9.96, 'lon': 76.28, 'name': 'Aakshaya Centre', 'icon': Icons.account_balance},
    {'category': MapCategory.governmentSupport, 'lat': 10.02, 'lon': 76.32, 'name': 'Collectorate Office', 'icon': Icons.gavel},
    {'category': MapCategory.sheltersHousing, 'lat': 9.99, 'lon': 76.27, 'name': 'Temporary Shelter', 'icon': Icons.house},
    {'category': MapCategory.sheltersHousing, 'lat': 10.05, 'lon': 76.35, 'name': 'Low-cost Hostel', 'icon': Icons.bed},
    {'category': MapCategory.foodSupplies, 'lat': 9.97, 'lon': 76.29, 'name': 'Community Kitchen', 'icon': Icons.restaurant},
    {'category': MapCategory.foodSupplies, 'lat': 10.01, 'lon': 76.26, 'name': 'Ration Shop', 'icon': Icons.shopping_cart},
    {'category': MapCategory.legalDocumentation, 'lat': 9.98, 'lon': 76.31, 'name': 'Legal Aid Clinic', 'icon': Icons.gavel},
    {'category': MapCategory.legalDocumentation, 'lat': 10.03, 'lon': 76.28, 'name': 'Aadhaar Centre', 'icon': Icons.badge},
    {'category': MapCategory.jobSkillCenters, 'lat': 9.975, 'lon': 76.305, 'name': 'Skill Training Centre', 'icon': Icons.work},
    {'category': MapCategory.jobSkillCenters, 'lat': 10.005, 'lon': 76.295, 'name': 'Employment Exchange', 'icon': Icons.business_center},
    {'category': MapCategory.educationChildcare, 'lat': 9.995, 'lon': 76.285, 'name': 'Bridge School', 'icon': Icons.school},
    {'category': MapCategory.educationChildcare, 'lat': 9.965, 'lon': 76.315, 'name': 'Anganwadi Centre', 'icon': Icons.child_care},
    {'category': MapCategory.placesOfWorship, 'lat': 9.988, 'lon': 76.288, 'name': 'Community Hall', 'icon': Icons.people},
    {'category': MapCategory.placesOfWorship, 'lat': 10.015, 'lon': 76.275, 'name': 'Temple', 'icon': Icons.temple_buddhist},
  ];

  @override
  void initState() {
    super.initState();
    fetchHospitalLocations(); // Fetch hospital data from data.gov.in
  }

  Future<void> fetchHospitalLocations() async {
    final url = Uri.parse(
        'https://api.data.gov.in/resource/579b464db66ec23bdd000001af10fc9b7e0e4fb0600a412c37e49a97?format=json&api-key=579b464db66ec23bdd000001af10fc9b7e0e4fb0600a412c37e49a97&limit=100');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> records = data['records'];

        setState(() {
          for (var record in records) {
            double? lat = double.tryParse(record['latitude'] ?? '');
            double? lon = double.tryParse(record['longitude'] ?? '');
            if (lat != null && lon != null) {
              _allLocations.add({
                'category': MapCategory.healthcare,
                'lat': lat,
                'lon': lon,
                'name': record['hospital_name'] ?? 'Hospital',
                'icon': Icons.local_hospital,
                'address': record['address'] ?? 'N/A', // Add more details from API if available
                'contact': record['contact_number'] ?? 'N/A',
              });
            }
          }
        });
      } else {
        print('Failed to load hospital data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hospital data: $e');
    }
  }

  // Helper method to build a consistent detail row with an icon
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Increased vertical padding for separation
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _mutedBlueGrey, size: 20), // Icon with muted color
          const SizedBox(width: 12), // Space between icon and text
          Expanded( // Ensures text wraps if long
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style!.copyWith(fontSize: 15), // Slightly larger text
                children: <TextSpan>[
                  TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), // Darker bold label
                  TextSpan(text: ' $value', style: const TextStyle(color: Colors.black)), // Value text
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(BuildContext context, Map<String, dynamic> location) {
    final MapCategory category = location['category'] as MapCategory;
    final String categoryDisplayName = category.displayName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Rounded corners for the dialog
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0), // More space above title
          contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 10.0), // Adjust content padding
          actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0), // Adjust action padding

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Larger and bolder title
                  color: _primaryDarkBlue, // Title color from palette
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: _mutedBlueGrey), // Subtle divider below title
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Make column take minimum space
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Category:',
                  value: categoryDisplayName,
                  context: context,
                ),
                _buildDetailRow(
                  icon: Icons.location_on, // Location icon for coordinates
                  label: 'Latitude:',
                  value: '${location['lat']}',
                  context: context,
                ),
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Longitude:',
                  value: '${location['lon']}',
                  context: context,
                ),
                if (location.containsKey('address') && location['address'] != 'N/A')
                  _buildDetailRow(
                    icon: Icons.home, // Home icon for address
                    label: 'Address:',
                    value: location['address'],
                    context: context,
                  ),
                if (location.containsKey('contact') && location['contact'] != 'N/A')
                  _buildDetailRow(
                    icon: Icons.phone, // Phone icon for contact
                    label: 'Contact:',
                    value: location['contact'],
                    context: context,
                  ),
                // Add more details rows here if your data contains them
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: _primaryDarkBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold button text
              ),
              child: const Text('CLOSE'), // Uppercase for emphasis
            ),
          ],
        );
      },
    );
  }

  List<Marker> _getMarkersForCategory() {
    return _allLocations
        .where((location) =>
            _selectedCategory == MapCategory.allLocations ||
            location['category'] == _selectedCategory)
        .map((location) {
      return Marker(
        point: LatLng(location['lat'], location['lon']),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () {
            _showLocationDetails(context, location);
          },
          child: Column(
            children: [
              Icon(
                location['icon'] as IconData,
                color: Colors.red.shade700, // Kept red for visibility
                size: 30,
              ),
              // Optional: Add name below marker
              // Text(location['name'], style: TextStyle(fontSize: 8)),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essential Locations'),
        backgroundColor: _primaryDarkBlue,
        foregroundColor: Colors.white,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<MapCategory>(
              value: _selectedCategory,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: _secondaryDarkBlue,
              style: const TextStyle(color: Colors.white),
              onChanged: (MapCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: MapCategory.values
                  .map<DropdownMenuItem<MapCategory>>((MapCategory category) {
                return DropdownMenuItem<MapCategory>(
                  value: category,
                  child: Text(
                    category.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(9.9667, 76.2833), // Approx. Marine Drive / Ernakulam
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.migrantconnectapp',
          ),
          MarkerLayer(
            markers: _getMarkersForCategory(),
          ),
        ],
      ),
    );
  }
}