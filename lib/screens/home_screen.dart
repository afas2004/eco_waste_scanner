import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import '../services/history_service.dart';
import 'camera_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanRecord> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  // Fetch data with visual feedback
  Future<void> _loadRecentActivity() async {
    final allHistory = await HistoryService.getHistory();
    
    if (mounted) {
      setState(() {
        _recentActivity = allHistory.take(3).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Dashboard updated"),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Dynamic Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textMain;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSub;

    return Scaffold(
      // 2. FIX: Use Dynamic Background Color instead of static AppColors.background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.recycling, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("EcoScan", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: subTextColor),
            onPressed: _loadRecentActivity,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. FIX: Use dynamic text colors
            Text("Hello", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            Text("Ready to classify waste?", style: GoogleFonts.inter(fontSize: 16, color: subTextColor)),
            const SizedBox(height: 24),
            
            // Hero Card (Start Scan)
            GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
                _loadRecentActivity();
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                  image: const DecorationImage(
                    image: AssetImage("assets/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text("AI Classifier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Identify Waste", style: AppTextStyles.cardTitle),
                    const Text("Plastic, Glass, Paper...", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text("Recent Activity", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            
            // Dynamic List
            if (_recentActivity.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, // Dynamic Card Color
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: subTextColor),
                    const SizedBox(width: 10),
                    Text("No recent scans found.", style: TextStyle(color: subTextColor)),
                  ],
                ),
              )
            else
              ..._recentActivity.map((record) => _buildActivityItem(record)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ScanRecord record) {
    // Dynamic Colors for List Items
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSub;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dynamic Card Color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.eco, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.result, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                ),
                Text(
                  DateFormat('h:mm a • MMM d').format(record.date), 
                  style: TextStyle(color: subTextColor, fontSize: 12)
                ),
              ],
            ),
          ),
          Container(
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
        ],
      ),
    );
  }
}