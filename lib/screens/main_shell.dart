import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/styles.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart'; // Add this import

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  // The 4 main pages for the bottom bar
  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
    const SettingsScreen(), // Moved Settings to the bottom bar for symmetry
  ];

  void _onScanPressed() async {
    // Open Camera
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    // When we return, if we are on Home or History, trigger a rebuild to show new data
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      // The Big Scan Button
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: _onScanPressed,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // The Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: Theme.of(context).cardColor,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween for even spacing
            children: [
              // Left Side
              Row(
                children: [
                  _buildTabItem(0, Icons.dashboard_rounded, "Home"),
                  const SizedBox(width: 20), // Spacing between icons
                  _buildTabItem(1, Icons.history_rounded, "History"),
                ],
              ),
              
              // Right Side (Profile & Settings)
              Row(
                children: [
                  _buildTabItem(2, Icons.person_rounded, "Profile"),
                  const SizedBox(width: 20), 
                  _buildTabItem(3, Icons.settings_rounded, "Settings"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? AppColors.primary : Colors.grey.shade400, 
              size: 26
            ),
            Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade400
              )
            ),
          ],
        ),
      ),
    );
  }
}