import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/sense_voice_service.dart';
import 'config/theme.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start STT model init in background so it's ready when needed
  SenseVoiceService.instance.init();
  runApp(const AppLoader());
}

/// Shows a simple loading screen while Hive initialises, then hands off
/// to [PinPinGoApp]. This keeps the Flutter engine rendering immediately
/// so Android's ANR watchdog is never triggered.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: StorageService.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError == false) {
          return const PinPinGoApp();
        }
        if (snapshot.hasError) {
          // Storage failed — still launch the app with empty state
          return const PinPinGoApp();
        }
        // Show a branded loading screen while Hive opens
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
