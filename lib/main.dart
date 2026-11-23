import 'package:ashlar_lawyer_hub/app.dart';
import 'package:ashlar_lawyer_hub/core/notifications/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.instance.bootstrap();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Avoid late font swap flicker after the first screen paints.
  await GoogleFonts.pendingFonts([
    GoogleFonts.openSans(),
    GoogleFonts.roboto(),
    GoogleFonts.inter(),
  ]);

  runApp(const AshlarLawyerHubApp());
}
