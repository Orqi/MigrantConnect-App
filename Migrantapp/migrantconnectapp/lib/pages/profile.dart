import 'package:flutter/material.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:magic_sdk/modules/user/user_response_type.dart';
import 'package:migrantconnectapp/main.dart'; // Assuming this imports `magic` instance

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserInfo? _user;
  String _name = "";
  File? _imageFile;
  String? _imageUrl;
  bool _isRegistered = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();

  // Define colors from the palette
  static const Color primaryColor = Color(0xFF133764); // Dark Blue
  static const Color accentColor = Color(0xFFF2B6B3); // Light Coral
  static const Color lightBackground = Color(0xFFFECBCC); // Light Pink
  static const Color secondaryColor = Color(0xFF0D3466); // Even Darker Blue
  static const Color greyText = Color(0xFF788DA0); // Muted Blue-Grey

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndRegistration();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatusAndRegistration() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isLoggedIn = await magic.user.isLoggedIn();
      if (isLoggedIn) {
        final userMetadata = await magic.user.getInfo();
        setState(() {
          _user = userMetadata;
        });

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString(userMetadata.email!);

        if (savedData != null) {
          final data = jsonDecode(savedData);
          setState(() {
            _name = data['name'];
            _imageUrl = data['imageUrl'];
            _isRegistered = true;
          });
          _showMessage('Loaded profile from local cache.');
        } else {
          _showMessage(
              'Profile not found locally, attempting to fetch from backend...');
          await _fetchUserProfileFromBackend(userMetadata.email!);
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      print('Error checking login status or fetching profile: $e');
      _showMessage('Error: Could not load profile. Please try again.');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfileFromBackend(String email) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.96.83.193:5001/user-profile?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['name'] != null && data['imageUrl'] != null) {
          setState(() {
            _name = data['name'];
            _imageUrl = data['imageUrl'];
            _isRegistered = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            email,
            jsonEncode({'name': _name, 'imageUrl': _imageUrl}),
          );
          _showMessage('✅ Profile fetched from backend and saved locally!');
        } else {
          _showMessage(
              'No registered profile found on backend for this email (invalid data).');
          setState(() {
            _isRegistered = false;
          });
        }
      } else if (response.statusCode == 404) {
        _showMessage('No profile found on backend for this email.');
        setState(() {
          _isRegistered = false;
        });
      } else {
        _showMessage(
            '❌ Failed to fetch profile from backend: ${response.statusCode}');
        print('Backend fetch error: ${response.statusCode} - ${response.body}');
        setState(() {
          if (!_isRegistered) {
            _isRegistered = false;
          }
        });
      }
    } catch (e) {
      _showMessage('❌ Error connecting to backend for profile: $e');
      print('Error fetching profile from backend: $e');
      setState(() {
        if (!_isRegistered) {
          _isRegistered = false;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        _showMessage('No image selected.');
      }
    });
  }

  Future<String?> _uploadToBackend() async {
    if (_imageFile == null) {
      _showMessage('No file selected for upload.');
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.96.83.193:5001/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
        filename: _imageFile!.path.split('/').last,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        final ipfsHash = data['ipfsHash'];
        final ipfsUrl = 'https://gateway.pinata.cloud/ipfs/$ipfsHash';
        _showMessage('📦 Uploaded to: $ipfsUrl');
        return ipfsUrl;
      } else {
        final errorBody = await response.stream.bytesToString();
        _showMessage(
            '❌ Error uploading to backend: ${response.statusCode} - $errorBody');
        print(
            'Error uploading to backend: ${response.statusCode} - $errorBody');
        return null;
      }
    } catch (e) {
      _showMessage('❌ Error uploading to backend: $e');
      print('Error uploading to backend: $e');
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerIdentity(String ipfsUrl) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://10.96.83.193:5001/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _user!.email!,
          'name': _name,
          'ipfsHash': ipfsUrl.split('/').last,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _user!.email!,
            jsonEncode({'name': _name, 'imageUrl': ipfsUrl}),
          );
          setState(() {
            _imageUrl = ipfsUrl;
            _isRegistered = true;
          });
          _showMessage('✅ Identity successfully registered!');
        } else {
          _showMessage('❌ Backend error: ${data['error']}');
          print('Backend error: ${data['error']}');
        }
      } else {
        _showMessage(
            '❌ Failed to register identity: ${response.statusCode} - ${response.body}');
        print(
            'Failed to register identity: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showMessage('❌ Error calling backend: $e');
      print('Error calling backend: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!(_user?.email != null) || _name.isEmpty || _imageFile == null) {
      _showMessage('Please log in, fill in name, and upload a file.');
      return;
    }

    final ipfsUrl = await _uploadToBackend();
    if (ipfsUrl == null) return;

    await _registerIdentity(ipfsUrl);
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await magic.user.logout();
      final prefs = await SharedPreferences.getInstance();
      if (_user != null && _user!.email != null) {
        await prefs.remove(_user!.email!);
      }
      setState(() {
        _user = null;
        _name = "";
        _imageFile = null;
        _imageUrl = null;
        _isRegistered = false;
        _nameController.clear();
      });
      _showMessage('Logged out successfully.');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _showMessage('Error during logout: $e');
      print('Logout error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: primaryColor, // Use primary color
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        color: lightBackground, // Set background color for the entire body
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.white, // Card background white for contrast
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isLoading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                              color: primaryColor), // Use primary color
                          const SizedBox(height: 16),
                          Text('Processing...',
                              style: TextStyle(
                                  fontSize: 18, color: greyText)), // Use greyText
                        ],
                      )
                    : _user == null
                        ? Text("User not logged in. Redirecting...",
                            style: TextStyle(color: greyText)) // Use greyText
                        : _buildProfileUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Profile Details',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor), // Use primary color
        ),
        const SizedBox(height: 10),
        Text(
          'Logged in as: ${_user?.email ?? 'N/A'}',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        Text(
          'Public Address: ${_user?.publicAddress ?? 'N/A'}',
          style: TextStyle(fontSize: 14, color: greyText), // Use greyText
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _isRegistered ? _buildRegisteredUserUI() : _buildRegistrationForm(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor, // Use accent color
            foregroundColor: secondaryColor, // Text color for contrast
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
            shadowColor: accentColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisteredUserUI() {
    return Column(
      children: [
        Text(
          'Name: $_name',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: secondaryColor), // Use secondary color
        ),
        const SizedBox(height: 15),
        Text(
          'Uploaded Image:',
          style: TextStyle(fontSize: 16, color: greyText), // Use greyText
        ),
        const SizedBox(height: 10),
        _imageUrl != null && _imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: lightBackground.withOpacity(0.5), // Use lightBackground
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: greyText.withOpacity(0.5)), // Use greyText
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: greyText), // Use greyText
                          Text('Image Load Error',
                              style: TextStyle(color: greyText)), // Use greyText
                        ],
                      ),
                    );
                  },
                ),
              )
            : Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: lightBackground.withOpacity(0.5), // Use lightBackground
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: greyText.withOpacity(0.5)), // Use greyText
                ),
                child: Center(
                  child: Text('No Image Available',
                      style: TextStyle(color: greyText)), // Use greyText
                ),
              ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        Text(
          'Register Your Identity',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor), // Use primary color
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          onChanged: (value) => _name = value,
          decoration: InputDecoration(
            labelText: 'Enter your name',
            labelStyle: TextStyle(color: greyText), // Use greyText
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor), // Focused border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greyText.withOpacity(0.5)), // Enabled border
            ),
            prefixIcon: const Icon(Icons.person, color: secondaryColor), // Use secondary color
            filled: true,
            fillColor: lightBackground.withOpacity(0.5), // Use lightBackground
          ),
        ),
        const SizedBox(height: 15),
        _imageFile == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor, // Use secondary color
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
              )
            : Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selected: ${_imageFile!.path.split('/').last}',
                    style: TextStyle(fontSize: 12, color: greyText), // Use greyText
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.change_circle),
                    label: const Text('Change Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor, // Use accent color
                      foregroundColor: secondaryColor, // Text color
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _handleRegister,
          icon: const Icon(Icons.app_registration),
          label: const Text('Register Identity'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Use primary color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}