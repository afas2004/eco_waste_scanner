import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';

class WasteClassifier {
  
  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, 
        isAsset: true,
        useGpuDelegate: false,
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Returns a String (e.g., "Plastic Bottle") instead of Int
  Future<String?> classifyFile(File imageFile) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 1,
        threshold: 0.1,   
        imageMean: 127.5, // REQUIRED for Color images (MobileNet)
        imageStd: 127.5,  // REQUIRED for Color images
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // MobileNet labels look like: "904 water bottle"
        // We often want to strip the ID number at the start
        String rawLabel = recognitions[0]['label'];
        return rawLabel.replaceAll(RegExp(r'[0-9]'), '').trim(); 
      }
    } catch (e) {
      print("Error classifying: $e");
    }
    return null;
  }
  
  void close() {
    Tflite.close();
  }
}