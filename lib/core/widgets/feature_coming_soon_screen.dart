import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:flutter/material.dart';

/// Simple placeholder for features not yet available in the app.
class FeatureComingSoonScreen extends StatelessWidget {
  const FeatureComingSoonScreen({
    super.key,
    required this.featureName,
    this.description,
  });

  final String featureName;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      background: const LawyerLoginGlowBackground(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset(
                AppAssets.walletBackButton,
                width: 28,
                height: 28,
              ),
            ),
            const Spacer(flex: 2),
            Text(
              featureName,
              style: AppTypography.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Coming soon',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description ??
                  'We are building this feature. It will be available in a future update.',
              style: AppTypography.inter(
                fontSize: 15,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
