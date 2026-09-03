import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User onboarding — Figma [`7125:585`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-585) (360×800).
///
/// Full artboard PNG + swipe Get Started overlay @ (19, 692).
class UserOnboardingScreen extends StatelessWidget {
  const UserOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userOnboardingScreenFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: s.s(19),
                  top: s.s(692),
                  width: s.s(324),
                  height: s.s(60),
                  child: GetStartedButton(
                    label: 'Get Started',
                    onComplete: () {
                      Navigator.of(context).pushNamed(UserRoutes.login);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
