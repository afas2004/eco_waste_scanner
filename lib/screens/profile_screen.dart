import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/styles.dart';
import '../services/history_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalItems = 0;
  String _lastItem = "None";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _totalItems = history.length;
        if (history.isNotEmpty) _lastItem = history.first.result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Text Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textMain;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSub;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Eco Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.primary), onPressed: _loadStats)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: const Icon(Icons.recycling, size: 50, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Text("Student Name", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                  Text("Eco-Warrior • Level ${_totalItems > 10 ? '2' : '1'}", style: GoogleFonts.inter(fontSize: 14, color: subTextColor)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Total Scans", "$_totalItems"),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildStatItem("Last Item", _lastItem),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // <--- DYNAMIC COLOR
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  _buildProfileRow(Icons.badge, "Student ID", "2023410638", textColor, subTextColor),
                  Divider(color: isDark ? Colors.white24 : Colors.grey.shade200),
                  _buildProfileRow(Icons.school, "Program", "CS240 - Bachelor of CS", textColor, subTextColor),
                  Divider(color: isDark ? Colors.white24 : Colors.grey.shade200),
                  _buildProfileRow(Icons.class_, "Course Code", "CSC661", textColor, subTextColor),
                  Divider(color: isDark ? Colors.white24 : Colors.grey.shade200),
                  _buildProfileRow(Icons.group, "Group", "RCS2405A", textColor, subTextColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, Color textCol, Color subTextCol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: subTextCol)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textCol)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value.length > 8 ? "${value.substring(0, 6)}..." : value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}