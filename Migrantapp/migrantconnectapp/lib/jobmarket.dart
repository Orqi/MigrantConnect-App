import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Required for jsonDecode

// --- Global variables provided by the Canvas environment ---
// These are placeholders for the actual values injected by the Canvas environment.
// In a real Flutter app, you would get your Supabase config from environment variables.
const String __app_id = 'com.example.migrantconnectapp'; // Placeholder for the actual app ID
const String __supabase_url = 'https://gqxgsgxvgutktndosfah.supabase.co'; // REPLACE WITH YOUR SUPABASE PROJECT URL
const String __supabase_anon_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGdzZ3h2Z3V0a3RuZG9zZmFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyNDY4MzQsImV4cCI6MjA2NzgyMjgzNH0.AkR1K1mqrnZpD6Qf13PCZhWR2lc9PwQS2XnW7SaTVRc'; // REPLACE WITH YOUR SUPABASE PROJECT ANON KEY

// --- Main Application Entry Point ---
void main() async {
  // Ensure Flutter binding is initialized. This is crucial before any Flutter-specific operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase. Await this call to ensure it completes before runApp.
  await Supabase.initialize(
    url: __supabase_url,
    anonKey: __supabase_anon_key,
    debug: true, // Set to false in production
  );

  // Now that Supabase is definitely initialized, run the app.
  runApp(const Jobmarket());
}

// --- MyApp Widget ---
class Jobmarket extends StatelessWidget {
  const Jobmarket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migrant Job Market',
      debugShowCheckedModeBanner: false, // <--- Add this line to remove the debug banner
      theme: ThemeData(
        // Define your color palette as Color objects
        // Use 0xFF prefix for ARGB hex values
        primaryColor: const Color(0xFF133764), // Dark Blue
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF133764), // Dark Blue for primary elements
          onPrimary: Colors.white, // White text/icons on primary background
          secondary: const Color(0xFFF2B6B3), // Coral/Peach for secondary elements
          onSecondary: Colors.black, // Black text/icons on secondary background
          surface: Colors.white, // White for cards, sheets, etc.
          onSurface: const Color(0xFF0D3466), // Darker Blue for text/icons on surface
          background: const Color(0xFFFECBCC), // Light Pink for overall background
          onBackground: const Color(0xFF0D3466), // Darker Blue for text/icons on background
          error: Colors.red, // Standard error color
          onError: Colors.white, // White text on error background
          // You can also add more specific colors if needed
          // tertiary: const Color(0xFF788DA0), // Muted Blue-Grey
          // onTertiary: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFFFECBCC), // Light Pink background for Scaffold
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D3466), // Even Darker Blue for AppBar
          foregroundColor: Colors.white, // White text/icons on AppBar
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.white, // Cards will be white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF133764), // Dark Blue for buttons
            foregroundColor: Colors.white, // White text on buttons
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF788DA0)), // Muted Blue-Grey border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0D3466), width: 2.0), // Darker Blue when focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF788DA0)), // Muted Blue-Grey border
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white, // Input fields background will be white
          labelStyle: const TextStyle(color: Color(0xFF0D3466)), // Darker Blue for labels
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        textTheme: const TextTheme(
          // Define default text styles with your colors
          displayLarge: TextStyle(color: Color(0xFF0D3466)),
          displayMedium: TextStyle(color: Color(0xFF0D3466)),
          displaySmall: TextStyle(color: Color(0xFF0D3466)),
          headlineLarge: TextStyle(color: Color(0xFF0D3466)),
          headlineMedium: TextStyle(color: Color(0xFF0D3466)),
          headlineSmall: TextStyle(color: Color(0xFF0D3466)),
          titleLarge: TextStyle(color: Color(0xFF0D3466)),
          titleMedium: TextStyle(color: Color(0xFF0D3466)),
          titleSmall: TextStyle(color: Color(0xFF0D3466)),
          bodyLarge: TextStyle(color: Color(0xFF0D3466)),
          bodyMedium: TextStyle(color: Color(0xFF0D3466)),
          bodySmall: TextStyle(color: Color(0xFF0D3466)),
          labelLarge: TextStyle(color: Color(0xFF0D3466)),
          labelMedium: TextStyle(color: Color(0xFF0D3466)),
          labelSmall: TextStyle(color: Color(0xFF0D3466)),
        ).apply(
          // Apply a default color for all text that doesn't have a specific color
          bodyColor: const Color(0xFF0D3466), // Default text color
          displayColor: const Color(0xFF0D3466), // Default text color for display
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const JobMarketplacePage(),
        '/landowner': (context) => const LandOwnerPage(),
        '/job_details': (context) => JobDetailsPage(
              job: ModalRoute.of(context)!.settings.arguments as Job,
            ),
      },
    );
  }
}

// --- Job Model ---
class Job {
  final String id;
  final String title;
  final String description;
  final String jobType;
  final String location;
  final String contactName;
  final String contactNumber;
  final String postedByUserId;
  final DateTime timestamp;
  final bool isActive;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.jobType,
    required this.location,
    required this.contactName,
    required this.contactNumber,
    required this.postedByUserId,
    required this.timestamp,
    this.isActive = true,
  });

  // Factory constructor to create a Job from a Supabase row (Map)
  factory Job.fromSupabase(Map<String, dynamic> data) {
    return Job(
      id: data['id'] as String, // Supabase usually returns 'id' as UUID string
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No description provided.',
      jobType: data['jobType'] ?? 'Other',
      location: data['location'] ?? 'Unknown Location',
      contactName: data['contactName'] ?? 'N/A',
      contactNumber: data['contactNumber'] ?? 'N/A',
      postedByUserId: data['postedByUserId'] ?? 'anonymous',
      timestamp: DateTime.parse(data['timestamp'] as String).toLocal(), // Parse ISO 8601 string
      isActive: data['isActive'] ?? true,
    );
  }

  // Method to convert a Job object to a Supabase row (Map) for insertion/update
  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'description': description,
      'jobType': jobType,
      'location': location,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'postedByUserId': postedByUserId,
      'timestamp': timestamp.toIso8601String(), // Convert to ISO 8601 string for Supabase
      'isActive': isActive,
    };
  }
}

// --- Job Marketplace Page (Migrant View) ---
class JobMarketplacePage extends StatefulWidget {
  const JobMarketplacePage({super.key});

  @override
  State<JobMarketplacePage> createState() => _JobMarketplacePageState();
}

class _JobMarketplacePageState extends State<JobMarketplacePage> {
  String? _selectedJobTypeFilter;
  final TextEditingController _locationFilterController = TextEditingController();
  // Removed _currentUserId as authentication is no longer required.

  @override
  void initState() {
    super.initState();
    // No need to fetch user ID if authentication is not required.
  }

  @override
  void dispose() {
    _locationFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Supabase client instance
    // This is safe here because main() guarantees initialization
    final SupabaseClient supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Market'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration( // Use InputDecoration from theme
                    labelText: 'Filter by Job Type',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedJobTypeFilter,
                  items: ['Agriculture', 'Construction', 'Domestic Help', 'Other']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedJobTypeFilter = value;
                    });
                  },
                  hint: const Text('Select Job Type'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface), // Apply text color
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationFilterController,
                  decoration: InputDecoration( // Use InputDecoration from theme
                    labelText: 'Filter by Location (e.g., City, State)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface), // Icon color
                      onPressed: () {
                        setState(() {
                          _locationFilterController.clear();
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      // Trigger rebuild with new location filter
                    });
                  },
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface), // Apply text color
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Removed the Padding widget that displayed the current user ID.
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Get the raw stream of all active jobs.
              // We will filter and sort this list in Dart.
              stream: supabase.from('jobs').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No jobs found.', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
                }

                // Convert raw data to Job objects and apply filters in Dart
                List<Job> allJobs = snapshot.data!.map((data) {
                  return Job.fromSupabase(data);
                }).toList();

                // Apply 'isActive' filter first (always true)
                List<Job> filteredJobs = allJobs.where((job) => job.isActive).toList();

                // Apply Job Type filter
                if (_selectedJobTypeFilter != null && _selectedJobTypeFilter!.isNotEmpty) {
                  filteredJobs = filteredJobs.where((job) => job.jobType == _selectedJobTypeFilter).toList();
                }

                // Apply Location filter (case-insensitive contains)
                if (_locationFilterController.text.trim().isNotEmpty) {
                  final String searchLocation = _locationFilterController.text.trim().toLowerCase();
                  filteredJobs = filteredJobs.where((job) =>
                    job.location.toLowerCase().contains(searchLocation)
                  ).toList();
                }

                // Sort the filtered jobs by timestamp (most recent first)
                filteredJobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                if (filteredJobs.isEmpty) {
                  return Center(child: Text('No jobs found matching your criteria.', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
                }


                return ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return Card(
                      child: ListTile(
                        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${job.jobType} - ${job.location}\nPosted: ${job.timestamp.toLocal().toString().split(' ')[0]}'),
                        onTap: () {
                          Navigator.pushNamed(context, '/job_details', arguments: job);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/landowner');
        },
        label: const Text('Are you a Land Owner?'),
        icon: const Icon(Icons.add_business),
        backgroundColor: Theme.of(context).colorScheme.secondary, // Coral/Peach for FAB
        foregroundColor: Theme.of(context).colorScheme.onSecondary, // Black text/icon on FAB
      ),
    );
  }
}

// --- Job Details Page ---
class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Type: ${job.jobType}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Location: ${job.location}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('Description:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(job.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Contact Information:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('Person: ${job.contactName}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Number: ', style: Theme.of(context).textTheme.bodyLarge),
                Text(job.contactNumber, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green), // Kept green for phone
                  onPressed: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: job.contactNumber,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch phone dialer.')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // The postedByUserId will now reflect 'guest_landowner' or similar
            Text('Posted by User ID: ${job.postedByUserId}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
            Text('Posted On: ${job.timestamp.toLocal().toString().split(' ')[0]}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// --- Land Owner Page (Job Submission Form) ---
class LandOwnerPage extends StatefulWidget {
  const LandOwnerPage({super.key});

  @override
  State<LandOwnerPage> createState() => _LandOwnerPageState();
}

class _LandOwnerPageState extends State<LandOwnerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedJobType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Since authentication is removed, use a static ID for the poster.
      // In a real app without auth, you might generate a UUID here if truly unique IDs are needed.
      final String userId = 'guest_landowner';
      final SupabaseClient supabase = Supabase.instance.client;

      try {
        final newJob = Job(
          id: '', // Supabase will generate this UUID
          title: _titleController.text,
          description: _descriptionController.text,
          jobType: _selectedJobType!,
          location: _locationController.text,
          contactName: _contactNameController.text,
          contactNumber: _contactNumberController.text,
          postedByUserId: userId,
          timestamp: DateTime.now(),
        );

        // Insert data into the 'jobs' table
        await supabase.from('jobs').insert(newJob.toSupabase());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job offer submitted successfully!')),
        );
        _formKey.currentState!.reset(); // Clear form
        setState(() {
          _selectedJobType = null; // Reset dropdown
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit job: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Job Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Job Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Job Type'),
                value: _selectedJobType,
                items: ['Agriculture', 'Construction', 'Domestic Help', 'Other']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a job type' : null,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface), // Apply text color
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (e.g., City, State)'),
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: 'Contact Person Name'),
                keyboardType: TextInputType.name,
                validator: (value) => value!.isEmpty ? 'Please enter a contact name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter a contact number' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitJob,
                child: const Text('Submit Job Offer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}