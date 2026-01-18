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
      print("MobileNet Model Loaded");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Returns a String (e.g., "Plastic Bottle") instead of Int
  Future<String?> classifyFile(File imageFile, {double threshold = 0.2}) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 1,
        threshold: threshold, // Use the variable here!
        imageMean: 127.5, 
        imageStd: 127.5,  
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // Labels often come like "904 water bottle". 
        // We remove the numbers to make it clean.
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