import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/features/splash/presentation/widgets/splash_glow_background.dart';
import 'package:ashlar_lawyer_hub/core/widgets/keyboard_dismissible.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDarkScaffold extends StatelessWidget {
  const AppDarkScaffold({
    super.key,
    required this.body,
    this.showGlow = true,
    this.useSafeArea = true,
    this.background,
    this.resizeToAvoidBottomInset = true,
    this.dismissKeyboardOnTap = false,
  });

  final Widget body;
  final bool showGlow;
  final bool useSafeArea;
  final Widget? background;
  final bool resizeToAvoidBottomInset;
  final bool dismissKeyboardOnTap;

  @override
  Widget build(BuildContext context) {
    var content = useSafeArea ? SafeArea(child: body) : body;
    if (dismissKeyboardOnTap) {
      content = KeyboardDismissOnTap(child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              background!
            else if (showGlow)
              const SplashGlowBackground(),
            content,
          ],
        ),
      ),
    );
  }
}
