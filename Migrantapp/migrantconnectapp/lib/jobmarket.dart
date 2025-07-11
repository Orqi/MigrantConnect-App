// lib/jobmarket.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Required for jsonDecode
import 'package:migrantconnectapp/l10n/app_localizations.dart'; // Import AppLocalizations

// --- Job Model (No changes needed here for localization) ---
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

  factory Job.fromSupabase(Map<String, dynamic> data) {
    return Job(
      id: data['id'] as String,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No description provided.',
      jobType: data['jobType'] ?? 'Other',
      location: data['location'] ?? 'Unknown Location',
      contactName: data['contactName'] ?? 'N/A',
      contactNumber: data['contactNumber'] ?? 'N/A',
      postedByUserId: data['postedByUserId'] ?? 'anonymous',
      timestamp: DateTime.parse(data['timestamp'] as String).toLocal(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'description': description,
      'jobType': jobType,
      'location': location,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'postedByUserId': postedByUserId,
      'timestamp': timestamp.toIso8601String(),
      'isActive': isActive,
    };
  }
}

// --- Job Market Page (This is the top-level page for the Job Market feature) ---
// It is no longer a MaterialApp itself.
class JobMarketPage extends StatelessWidget {
  const JobMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget now serves as the container for the job market feature.
    // It directly returns the JobMarketplacePage, which contains the Scaffold, AppBar, etc.
    return const JobMarketplacePage();
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

  @override
  void dispose() {
    _locationFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final appLocalizations = AppLocalizations.of(context)!; // Access localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.jobMarket), // Localized
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: appLocalizations.filterByJobType, // Localized
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedJobTypeFilter,
                  items: [
                    DropdownMenuItem(value: 'Agriculture', child: Text(appLocalizations.jobTypeAgriculture)),
                    DropdownMenuItem(value: 'Construction', child: Text(appLocalizations.jobTypeConstruction)),
                    DropdownMenuItem(value: 'Domestic Help', child: Text(appLocalizations.jobTypeDomesticHelp)),
                    DropdownMenuItem(value: 'Other', child: Text(appLocalizations.jobTypeOther)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedJobTypeFilter = value;
                    });
                  },
                  hint: Text(appLocalizations.selectJobType), // Localized
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationFilterController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.filterByLocation, // Localized
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('jobs').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${appLocalizations.error}: ${snapshot.error}')); // Localized
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(appLocalizations.noJobsFound, style: TextStyle(color: Theme.of(context).colorScheme.onBackground))); // Localized
                }

                List<Job> allJobs = snapshot.data!.map((data) {
                  return Job.fromSupabase(data);
                }).toList();

                List<Job> filteredJobs = allJobs.where((job) => job.isActive).toList();

                if (_selectedJobTypeFilter != null && _selectedJobTypeFilter!.isNotEmpty) {
                  filteredJobs = filteredJobs.where((job) => job.jobType == _selectedJobTypeFilter).toList();
                }

                if (_locationFilterController.text.trim().isNotEmpty) {
                  final String searchLocation = _locationFilterController.text.trim().toLowerCase();
                  filteredJobs = filteredJobs.where((job) =>
                    job.location.toLowerCase().contains(searchLocation)
                  ).toList();
                }

                filteredJobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                if (filteredJobs.isEmpty) {
                  return Center(child: Text(appLocalizations.noJobsFoundMatchingCriteria, style: TextStyle(color: Theme.of(context).colorScheme.onBackground))); // Localized
                }

                return ListView.builder(
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return Card(
                      child: ListTile(
                        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${appLocalizations.jobType}: ${job.jobType} - ${appLocalizations.location}: ${job.location}\n${appLocalizations.posted}: ${job.timestamp.toLocal().toString().split(' ')[0]}'), // Localized
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
        label: Text(appLocalizations.areYouALandOwner), // Localized
        icon: const Icon(Icons.add_business),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
    final appLocalizations = AppLocalizations.of(context)!; // Access localized strings

    return Scaffold(
      appBar: AppBar(title: Text(job.title)), // Job title remains dynamic
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appLocalizations.jobType}: ${job.jobType}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), // Localized
            const SizedBox(height: 8),
            Text('${appLocalizations.location}: ${job.location}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), // Localized
            const SizedBox(height: 16),
            Text('${appLocalizations.description}:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Localized
            Text(job.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('${appLocalizations.contactInformation}:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Localized
            Text('${appLocalizations.person}: ${job.contactName}', style: Theme.of(context).textTheme.bodyLarge), // Localized
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${appLocalizations.number}: ', style: Theme.of(context).textTheme.bodyLarge), // Localized
                Text(job.contactNumber, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: job.contactNumber,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(appLocalizations.couldNotLaunchPhoneDialer)), // Localized
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${appLocalizations.postedByUserId}: ${job.postedByUserId}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)), // Localized
            Text('${appLocalizations.postedOn}: ${job.timestamp.toLocal().toString().split(' ')[0]}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)), // Localized
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

      final String userId = 'guest_landowner';
      final SupabaseClient supabase = Supabase.instance.client;
      final appLocalizations = AppLocalizations.of(context)!;

      try {
        final newJob = Job(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          jobType: _selectedJobType!,
          location: _locationController.text,
          contactName: _contactNameController.text,
          contactNumber: _contactNumberController.text,
          postedByUserId: userId,
          timestamp: DateTime.now(),
        );

        await supabase.from('jobs').insert(newJob.toSupabase());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.jobOfferSubmittedSuccessfully)),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedJobType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appLocalizations.failedToSubmitJob}: $e')),
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
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.submitJobOffer)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: appLocalizations.jobTitle),
                validator: (value) => value!.isEmpty ? appLocalizations.pleaseEnterATitle : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: appLocalizations.jobDescription),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? appLocalizations.pleaseEnterADescription : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: appLocalizations.jobType),
                value: _selectedJobType,
                items: [
                  DropdownMenuItem(value: 'Agriculture', child: Text(appLocalizations.jobTypeAgriculture)),
                  DropdownMenuItem(value: 'Construction', child: Text(appLocalizations.jobTypeConstruction)),
                  DropdownMenuItem(value: 'Domestic Help', child: Text(appLocalizations.jobTypeDomesticHelp)),
                  DropdownMenuItem(value: 'Other', child: Text(appLocalizations.jobTypeOther)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value;
                  });
                },
                validator: (value) => value == null ? appLocalizations.pleaseSelectAJobType : null,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: appLocalizations.locationHint),
                validator: (value) => value!.isEmpty ? appLocalizations.pleaseEnterALocation : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(labelText: appLocalizations.contactPersonName),
                keyboardType: TextInputType.name,
                validator: (value) => value!.isEmpty ? appLocalizations.pleaseEnterAContactName : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: appLocalizations.contactNumber),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? appLocalizations.pleaseEnterAContactNumber : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitJob,
                child: Text(appLocalizations.submitJobOfferButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}