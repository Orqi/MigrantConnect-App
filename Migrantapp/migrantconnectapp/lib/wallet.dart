import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking from gallery
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'dart:io'; // For File operations

// --- Color Constants ---
// Define the custom colors from the provided hex codes
const Color primaryColor = Color(0xFF133764); // Dark Blue
const Color accentColor = Color(0xFFF2B6B3);  // Light Coral/Pink
const Color secondaryColor = Color(0xFF788DA0); // Greyish Blue
const Color darkAccentColor = Color(0xFF0D3466); // Even Darker Blue
const Color lightBackgroundColor = Color(0xFFFECBCC); // Light Pink/Peach
const Color whiteColor = Colors.white;

// --- Supabase Configuration (PLACEHOLDERS) ---
// IMPORTANT: Replace with your actual Supabase URL and Anon Key
// You should ideally manage these securely, e.g., using environment variables.
const String supabaseUrl = 'https://gqxgsgxvgutktndosfah.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGdzZ3h2Z3V0a3RuZG9zZmFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyNDY4MzQsImV4cCI6MjA2NzgyMjgzNH0.AkR1K1mqrnZpD6Qf13PCZhWR2lc9PwQS2XnW7SaTVRc';

// --- WalletScreen Widget ---
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final SupabaseClient _supabase;
  bool _isLoading = false;
  String? _message; // For displaying success/error messages

  // List to hold metadata of uploaded documents
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    // Initialize Supabase client
    _supabase = Supabase.instance.client;
    // Fetch existing documents when the screen initializes
    _fetchDocuments();
  }

  // --- Image Picking and Upload Logic ---
  Future<void> _pickAndUploadFile(String documentType) async {
    // Check if a document of this type has already been uploaded
    if (_documents.any((doc) => doc['document_type'] == documentType)) {
      setState(() {
        _message = 'You can only upload one $documentType.';
      });
      return; // Prevent further execution if already uploaded
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Use ImagePicker to pick an image from the gallery
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final fileBytes = await image.readAsBytes();
        final fileName = image.name;
        final fileExtension = fileName.split('.').last;
        final uniqueFileName = '${const Uuid().v4()}.$fileExtension'; // Generate unique ID

        // Determine the Supabase bucket based on document type
        String bucketName;
        switch (documentType) {
          case 'Education Certificate':
            bucketName = 'education'; // Updated bucket name
            break;
          case 'PAN Card':
            bucketName = 'pan'; // Updated bucket name
            break;
          case 'Driver\'s License':
            bucketName = 'driver'; // Updated bucket name
            break;
          default:
            throw Exception('Unknown document type');
        }

        // Upload the file to Supabase Storage
        // The path in Supabase Storage will be like "Education Certificate/unique-id.jpg"
        final filePath = '$documentType/$uniqueFileName';
        await _supabase.storage.from(bucketName).uploadBinary(
              filePath,
              fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600', // Cache for 1 hour
                upsert: false,        // Do not overwrite if file exists
              ),
            );

        // Get the public URL of the uploaded file
        final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

        // Insert metadata into a Supabase database table (e.g., 'documents')
        await _supabase.from('documents').insert({
          'document_type': documentType,
          'supabase_file_path': filePath,
          'supabase_bucket': bucketName,
          'public_url': publicUrl, // Store the public URL for easy display
          'uploaded_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _message = 'Successfully uploaded $documentType!';
        });
        _fetchDocuments(); // Refresh the list of documents
      } else {
        setState(() {
          _message = 'No image selected from gallery.';
        });
      }
    } on StorageException catch (e) {
      setState(() {
        _message = 'Storage Error: ${e.message}';
      });
    } on PostgrestException catch (e) {
      setState(() {
        _message = 'Database Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Fetch Documents from Supabase Database ---
  Future<void> _fetchDocuments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch all documents from the 'documents' table
      final response = await _supabase
          .from('documents')
          .select()
          .order('uploaded_at', ascending: false); // Order by most recent first

      setState(() {
        _documents = List<Map<String, dynamic>>.from(response);
      });
    } on PostgrestException catch (e) {
      setState(() {
        _message = 'Error fetching documents: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Permanent Document Wallet',
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: lightBackgroundColor, // Overall background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Upload Section ---
            Card(
              color: whiteColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Upload New Document',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkAccentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadButton('Education Certificate'),
                    const SizedBox(height: 10),
                    _buildUploadButton('PAN Card'),
                    const SizedBox(height: 10),
                    _buildUploadButton('Driver\'s License'),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(darkAccentColor),
                        ),
                      ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _message!.contains('Error') ? Colors.red : darkAccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Uploaded Documents Section ---
            Text(
              'My Uploaded Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _documents.isEmpty
                  ? Center(
                      child: Text(
                        'No documents uploaded yet.',
                        style: TextStyle(fontSize: 16, color: secondaryColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final doc = _documents[index];
                        final uploadedAt = DateTime.parse(doc['uploaded_at']);
                        final formattedDate =
                            '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: whiteColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: secondaryColor.withOpacity(0.5), width: 1),
                          ),
                          child: InkWell( // Added InkWell for tap functionality
                            onTap: () {
                              // Navigate to a new screen to view the full document
                              if (doc['public_url'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DocumentViewerScreen(
                                      imageUrl: doc['public_url'],
                                      documentType: doc['document_type'],
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _message = 'Document URL not available.';
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Document Icon/Thumbnail
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: lightBackgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: secondaryColor.withOpacity(0.3)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: doc['public_url'] != null
                                          ? Image.network(
                                              doc['public_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                _getIconForDocumentType(doc['document_type']),
                                                color: primaryColor,
                                                size: 30,
                                              ),
                                            )
                                          : Icon(
                                              _getIconForDocumentType(doc['document_type']),
                                              color: primaryColor,
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc['document_type'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: darkAccentColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Uploaded: $formattedDate',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build consistent upload buttons
  Widget _buildUploadButton(String documentType) {
    final bool alreadyUploaded = _documents.any((doc) => doc['document_type'] == documentType);

    return ElevatedButton.icon(
      onPressed: (_isLoading || alreadyUploaded) ? null : () => _pickAndUploadFile(documentType),
      icon: Icon(Icons.upload_file, color: whiteColor),
      label: Text(
        alreadyUploaded ? '$documentType Uploaded' : 'Upload $documentType',
        style: const TextStyle(color: whiteColor, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: alreadyUploaded ? secondaryColor : primaryColor, // Change color if uploaded
        foregroundColor: whiteColor, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 5,
        minimumSize: const Size(double.infinity, 50), // Full width button
      ),
    );
  }

  // Helper to get appropriate icon for document type
  IconData _getIconForDocumentType(String documentType) {
    switch (documentType) {
      case 'Education Certificate':
        return Icons.school;
      case 'PAN Card':
        return Icons.credit_card;
      case 'Driver\'s License':
        return Icons.directions_car;
      default:
        return Icons.document_scanner;
    }
  }
}

// --- New Widget for Document Viewing ---
class DocumentViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String documentType;

  const DocumentViewerScreen({
    super.key,
    required this.imageUrl,
    required this.documentType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          documentType,
          style: const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor), // Back button color
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain, // Ensure the entire image is visible
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(darkAccentColor),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Could not load image.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: lightBackgroundColor, // Background color for the viewer screen
    );
  }
}
