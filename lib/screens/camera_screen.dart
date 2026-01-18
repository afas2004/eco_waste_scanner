import 'dart:io';
// Add this alias to avoid conflicts with Flutter's Image widget
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // to access 'cameras'
import '../services/waste_classifier.dart';
import '../utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';
import 'settings_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final WasteClassifier _classifier = WasteClassifier();
  bool _isProcessing = false;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAI();
    _initializeCamera();
    _classifier.loadModel();
  }

  Future<void> _initAI() async {
    await _classifier.loadModel();
    if (mounted) setState(() => _isModelLoaded = true);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        // 1. LOWER RESOLUTION: 'medium' is the sweet spot for TFLite on phones.
        // 'max' or 'high' often causes the buffer error you saw.
        ResolutionPreset.low, 
        
        // 2. DISABLE AUDIO: Critical! If this is true (default) but you 
        // didn't ask for microphone permission, the camera crashes silently.
        enableAudio: false, 
        
        // 3. FIX BUFFER ISSUE: This helps Android process frames smoothly
        imageFormatGroup: ImageFormatGroup.yuv420, 
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  Future<void> _captureAndPredict() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // --- FIX STARTS HERE ---
      
      // 1. Capture FIRST (Do not pause before this!)
      // The camera needs the preview running to focus.
      final XFile image = await _controller!.takePicture();
      
      // 2. NOW Pause (To freeze the screen for visual effect)
      await _controller!.pausePreview();

      // --- FIX ENDS HERE ---

      File originalFile = File(image.path);

      // 3. SAFE RESIZE (Keep this! It prevents the crash)
      final rawImage = img.decodeImage(await originalFile.readAsBytes());
      
      if (rawImage != null) {
        // Resize to 224x224 (Standard MobileNet size)
        final resizedImage = img.copyResize(rawImage, width: 224, height: 224);
        
        final tempDir = originalFile.parent;
        final resizedFile = File('${tempDir.path}/resized_temp.jpg');
        await resizedFile.writeAsBytes(img.encodeJpg(resizedImage));
        
        originalFile = resizedFile;
      }

      // 4. Get Threshold & Predict
      final prefs = await SharedPreferences.getInstance();
      double savedThreshold = prefs.getDouble('confidenceThreshold') ?? 50.0;
      double modelThreshold = savedThreshold / 100.0;

      String? result = await _classifier.classifyFile(originalFile, threshold: modelThreshold);

      if (mounted && result != null) {
        _showResultDialog(result, originalFile);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Not confident enough. Try getting closer.")),
        );
        await _controller!.resumePreview();
      }
    } catch (e) {
      print("Error: $e");
      await _controller?.resumePreview();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(String label, File image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be taller
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        // Make it take up 75% of the screen so the image is big
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Uses your Dark/Light theme
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle Bar
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            
            // --- NEW: IMAGE PREVIEW ---
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  image, 
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --------------------------

            Text("Identified Item", style: AppTextStyles.body),
            const SizedBox(height: 10),
            
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Important: Turn camera back on if they retry
                      await _controller?.resumePreview();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary), // Green border
                    ),
                    child: const Text("Retry", style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Save to History (Text Data)
                      await HistoryService.addScan(label, 0.95, "Eco Scan");
                      if (context.mounted) {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close camera
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Saved to Eco History!"), backgroundColor: Colors.green),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraPreview(_controller!)),
          
          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Capture Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: GestureDetector(
                onTap: (_isProcessing || !_isModelLoaded) ? null : _captureAndPredict,
                child: Container(
                  height: 80, 
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: AppColors.primary) 
                      : Icon(Icons.camera_alt, color: _isModelLoaded ? AppColors.primary : Colors.grey, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}