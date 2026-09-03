import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:flutter/material.dart';

class LawyerDashboardPlaceholderScreen extends StatelessWidget {
  const LawyerDashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Lawyer dashboard coming next.\nShare the Dashboard Figma frame when ready.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
          ),
        ),
      ),
    );
  }
}
