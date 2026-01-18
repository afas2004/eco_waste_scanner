import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../utils/styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await HistoryService.getHistory();
    if (mounted) setState(() => _records = data);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Text Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Scan History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadData();
            },
          )
        ],
      ),
      body: _records.isEmpty
          ? Center(child: Text("No scans yet.", style: TextStyle(color: subTextColor)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).cardColor, // <--- DYNAMIC COLOR
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.eco, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      record.result,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor), // <--- DYNAMIC
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, h:mm a').format(record.date),
                      style: TextStyle(fontSize: 12, color: subTextColor), // <--- DYNAMIC
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${(record.confidence * 100).toInt()}%",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}