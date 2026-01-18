import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_shell.dart';
import 'utils/styles.dart';

List<CameraDescription> cameras = [];

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'EcoScan',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          
          // --- LIGHT THEME (Day) ---
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Light Mint
            cardColor: Colors.white,
            brightness: Brightness.light,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- DARK ECO THEME (Night) ---
          darkTheme: ThemeData(
            primaryColor: AppColors.primary,
            // Use a Very Dark Green instead of Black
            scaffoldBackgroundColor: const Color(0xFF051F0E), 
            // Use a Deep Forest Green for Cards
            cardColor: const Color(0xFF0F2E1B), 
            brightness: Brightness.dark,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Color(0xFFE8F5E9)), // Light Green Text
              bodyLarge: TextStyle(color: Colors.white),
            ),
          ),
          
          home: const MainShell(),
        );
      },
    );
  }
}