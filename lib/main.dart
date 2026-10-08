import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 🔴 1. Firebase Options Import
import 'firebase_options.dart'; 
import 'features/auth/screens/splash_screen.dart'; 
import 'core/services/push_notification_service.dart'; // Apna path verify kar lena
import 'core/services/local_notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔴 2. Options Parameter Added
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
    await PushNotificationService().initialize();
    // 🟢 Local Notification Engine Start
  await LocalNotificationService().init();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ ENV file loaded successfully!");
  } catch (e) {
    debugPrint("⚠️ ENV load warning (Ignore if testing on Web): $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ScholrX',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // 🔴 Strictly Light Mode for bright look
      theme: AppTheme.lightTheme,
      // (
      //   brightness: Brightness.light,
      //   primaryColor: Colors.indigoAccent, // Engaging Bright Blue/Indigo
      //   scaffoldBackgroundColor: const Color(0xFFF4F7FC), // Soft vibrant background
      //   colorScheme: const ColorScheme.light(
      //     primary: Colors.indigoAccent,
      //     secondary: Colors.deepPurpleAccent,
      //     surface: Colors.white,
      //     onSurface: Color(0xFF2D3142), // Dark Slate for crisp text
      //   ),
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     iconTheme: IconThemeData(color: Colors.indigoAccent),
      //     titleTextStyle: TextStyle(color: Color(0xFF2D3142), fontSize: 20, fontWeight: FontWeight.bold),
      //   ),
      // ),
      home: const ScholrxSplashScreen(), 
    );
  }
}