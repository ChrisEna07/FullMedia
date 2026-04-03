import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:full_media/modules/player/player_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FullMediaApp());
}

class FullMediaApp extends StatelessWidget {
  const FullMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FullMedia by Chrizdev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class PermissionHandlerManager {
  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        // 🔥 Android 13+
        await Permission.audio.request();

        // 🔥 Compatibilidad versiones viejas
        await Permission.storage.request();

        debugPrint("✅ Permisos solicitados");
      }
    } catch (e) {
      debugPrint("❌ Error solicitando permisos: $e");
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    try {
      // ⏳ Animación inicial
      await Future.delayed(const Duration(seconds: 2));

      // 🔐 Pedir permisos
      await PermissionHandlerManager.requestPermissions();

      await Future.delayed(const Duration(milliseconds: 500));

      // 🚀 Navegar
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      }
    } catch (e) {
      debugPrint("❌ Error en splash: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/FMCD.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.play_circle_fill,
                      size: 100,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "FULLMEDIA",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
            const Text(
              "PRO PLAYER",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueAccent,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
