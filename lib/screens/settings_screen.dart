import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/styles.dart';
import '../services/history_service.dart';
import '../main.dart'; // Import to access themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _confidenceThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _confidenceThreshold = prefs.getDouble('confidenceThreshold') ?? 50.0;
    });
  }

  Future<void> _toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', val);
    
    setState(() => _isDarkMode = val);
    // CRITICAL: Tell the whole app to switch modes
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _updateThreshold(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('confidenceThreshold', val);
    setState(() => _confidenceThreshold = val);
  }

  Future<void> _handleClearHistory() async {
    // ... (Keep your clear history logic here, it was fine) ...
    // Just re-adding the minimal logic for completeness
    await HistoryService.clearHistory();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("History cleared")));
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC COLORS: Get colors from the current Theme
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textMain;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Preferences"),
            _settingCard(
              color: cardColor, // Use Dynamic Color
              child: SwitchListTile(
                title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                value: _isDarkMode,
                activeColor: AppColors.primary,
                onChanged: _toggleDarkMode,
              ),
            ),
            
            const SizedBox(height: 24),
            
            _sectionHeader("AI Configuration"),
            _settingCard(
              color: cardColor, // Use Dynamic Color
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sensitivity", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      Text("${_confidenceThreshold.toInt()}%", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _confidenceThreshold,
                    min: 10, max: 90,
                    activeColor: AppColors.primary,
                    onChanged: _updateThreshold,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionHeader("Data"),
            _settingCard(
              color: cardColor, // Use Dynamic Color
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Clear History", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: _handleClearHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _settingCard({required Widget child, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color, // Uses the dynamic color passed in
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: child,
    );
  }
}