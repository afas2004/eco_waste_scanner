import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRecord {
  final String result;
  final double confidence;
  final DateTime date;
  final String type;

  ScanRecord({
    required this.result,
    required this.confidence,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'result': result,
    'confidence': confidence,
    'date': date.toIso8601String(),
    'type': type,
  };

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      // Default to "Unknown" if data is missing (Prevents Crashes)
      result: json['result'] ?? "Unknown Item",
      // Handle cases where confidence might be stored as int or double
      confidence: (json['confidence'] is int) 
          ? (json['confidence'] as int).toDouble() 
          : (json['confidence'] ?? 0.0),
      date: DateTime.tryParse(json['date'] ?? "") ?? DateTime.now(),
      type: json['type'] ?? 'Eco Scan',
    );
  }
}

class HistoryService {
  static const String _key = 'scan_history';

  // Add a new scan
  static Future<void> addScan(String result, double confidence, String type) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_key) ?? [];
    
    final newRecord = ScanRecord(
      result: result,
      confidence: confidence,
      date: DateTime.now(),
      type: type,
    );
    
    // Add to top
    historyList.insert(0, jsonEncode(newRecord.toJson()));
    await prefs.setStringList(_key, historyList);
  }

  // Get all scans (with error handling)
  static Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_key) ?? [];
    
    List<ScanRecord> cleanList = [];
    
    for (String item in historyList) {
      try {
        // Try to decode. If it fails (old data), skip it.
        final decoded = jsonDecode(item);
        cleanList.add(ScanRecord.fromJson(decoded));
      } catch (e) {
        print("Skipping corrupted record: $e");
      }
    }
    return cleanList;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}