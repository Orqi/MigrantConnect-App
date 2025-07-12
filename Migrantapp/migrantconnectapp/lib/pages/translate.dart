import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart'; // Import the translator package

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  File? _image;
  String _extractedText = 'No text recognized yet.';
  String _translatedTextHindi = 'No Hindi translation yet.';
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();
  final GoogleTranslator translator = GoogleTranslator(); // Create an instance of GoogleTranslator

  Future<void> _pickImage({ImageSource source = ImageSource.camera}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _extractedText = 'Recognizing text...';
      _translatedTextHindi = 'Translating to Hindi...';
      _isProcessing = true;
    });

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final text = recognizedText.text;

      setState(() {
        _extractedText = text.isEmpty ? 'No text found' : text;
      });

      if (text.isNotEmpty) {
        await _translateTextToHindi(text);
      } else {
        setState(() {
          _translatedTextHindi = 'Nothing to translate.';
        });
      }
    } catch (e) {
      setState(() {
        _extractedText = 'Error recognizing text: $e';
        _translatedTextHindi = 'Error translating text: $e';
      });
    } finally {
      await textRecognizer.close();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _translateTextToHindi(String text) async {
    try {
      Translation translation = await translator.translate(text, to: 'hi');
      setState(() {
        _translatedTextHindi = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedTextHindi = 'Translation failed: $e';
      });
    }
  }

  void _clearScanner() {
    setState(() {
      _image = null;
      _extractedText = 'No text recognized yet.';
      _translatedTextHindi = 'No Hindi translation yet.';
      _isProcessing = false;
    });
  }

  void _copyToClipboard({bool isTranslated = false}) {
    String textToCopy = isTranslated ? _translatedTextHindi : _extractedText;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isTranslated ? "Hindi text" : "Original text"} copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define your custom colors
    const Color primaryLight = Color(0xFF0D3466); // Dark blue for light theme primary
    const Color secondaryLight = Color(0xFF133764); // Slightly different dark blue
    const Color tertiaryLight = Color(0xFFF2B6B3); // Pinkish for light theme tertiary
    const Color accentColorLight = Color(0xFFFECBCC); // Lighter pink for light theme accent/secondary
    const Color greyBlue = Color(0xFF788DA0); // Muted grayish blue

    // For dark mode, we can use the same colors but perhaps swap some roles
    // or use light colors for backgrounds and dark for text.
    // It's often good to use the light theme's primary as inversePrimary in dark theme.
    const Color primaryDark = Color(0xFFF2B6B3); // Pinkish for dark theme primary
    const Color secondaryDark = Color(0xFFFECBCC); // Lighter pink for dark theme secondary
    const Color tertiaryDark = Color(0xFF788DA0); // Muted grayish blue for dark theme tertiary
    const Color backgroundDark = Color(0xFF133764); // Dark blue for dark theme background
    const Color surfaceDark = Color(0xFF0D3466); // Very dark blue for dark theme surface


    // You'll typically define your app's theme in your main.dart file
    // and access it using Theme.of(context).
    // For demonstration, I'm setting it up here.
    // In your actual app, this setup should be in MaterialApp's theme property.

    // Get current theme from context to check for dark mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on theme mode
    Color currentPrimary = isDarkMode ? primaryDark : primaryLight;
    Color currentOnPrimary = isDarkMode ? Colors.black : Colors.white; // Text on primary
    Color currentSecondary = isDarkMode ? secondaryDark : secondaryLight;
    Color currentOnSecondary = isDarkMode ? Colors.black : Colors.white; // Text on secondary
    Color currentTertiary = isDarkMode ? tertiaryDark : tertiaryLight;
    Color currentOnTertiary = isDarkMode ? Colors.black : Colors.black; // Text on tertiary
    Color currentSurface = isDarkMode ? surfaceDark : Colors.white; // Background of cards/containers
    Color currentOnSurface = isDarkMode ? Colors.white : Colors.black; // Text on surface
    Color currentBackground = isDarkMode ? backgroundDark : Colors.white; // Main Scaffold background
    Color currentOnBackground = isDarkMode ? Colors.white : Colors.black; // Text on background
    Color currentInversePrimary = isDarkMode ? primaryLight : primaryDark; // Used for icon/text against app bar when primary is dark

    return Scaffold(
      backgroundColor: currentBackground, // Apply background color
      appBar: AppBar(
        title: Text(
          'Smart Document Translator',
          style: TextStyle(
            color: currentOnPrimary, // Text color on primary background
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: currentPrimary, // App bar background
        iconTheme: IconThemeData(
          color: currentOnPrimary, // Icon color on primary background
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: currentSurface, // Container background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentSecondary, width: 1), // Border color
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: _image != null
                  ? Image.file(_image!, height: 220, fit: BoxFit.cover, width: double.infinity)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 70,
                          color: currentOnSurface.withOpacity(0.6), // Icon color
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Scan a Document to get started',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: currentOnSurface.withOpacity(0.8), // Text color
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(source: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPrimary, // Button background
                      foregroundColor: currentOnPrimary, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(source: ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTertiary, // Button background
                      foregroundColor: currentOnTertiary, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearScanner,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentSecondary, // Button background
                      foregroundColor: currentOnSecondary, // Button text/icon color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: currentSurface, // Container background
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Extracted Text (Original):',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: currentSecondary, // Text color
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, color: currentPrimary), // Icon color
                                onPressed: _extractedText == 'No text recognized yet.' ||
                                        _extractedText == 'Recognizing text...' ||
                                        _extractedText == 'No text found' ||
                                        _extractedText.startsWith('Error recognizing text:')
                                    ? null
                                    : () => _copyToClipboard(isTranslated: false),
                                tooltip: 'Copy Original Text',
                              ),
                            ],
                          ),
                          Divider(height: 20, thickness: 1, color: currentSecondary.withOpacity(0.3)), // Divider color
                          const SizedBox(height: 8),
                          _isProcessing
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(currentPrimary), // Progress indicator color
                                    ),
                                  ),
                                )
                              : SelectableText(
                                  _extractedText,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: currentOnSurface, // Text color
                                    height: 1.5,
                                  ),
                                ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: currentSurface, // Container background
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Translated Text (Hindi):',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: currentSecondary, // Text color
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, color: currentPrimary), // Icon color
                                onPressed: _translatedTextHindi == 'No Hindi translation yet.' ||
                                        _translatedTextHindi == 'Translating to Hindi...' ||
                                        _translatedTextHindi == 'Nothing to translate.' ||
                                        _translatedTextHindi.startsWith('Error translating text:')
                                    ? null
                                    : () => _copyToClipboard(isTranslated: true),
                                tooltip: 'Copy Hindi Text',
                              ),
                            ],
                          ),
                          Divider(height: 20, thickness: 1, color: currentSecondary.withOpacity(0.3)), // Divider color
                          const SizedBox(height: 8),
                          _isProcessing
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(currentPrimary), // Progress indicator color
                                    ),
                                  ),
                                )
                              : SelectableText(
                                  _translatedTextHindi,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: currentOnSurface, // Text color
                                    height: 1.5,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}