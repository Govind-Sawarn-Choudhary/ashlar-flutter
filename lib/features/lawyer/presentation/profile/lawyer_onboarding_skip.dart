import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:flutter/material.dart';

/// Skip remaining onboarding and open the lawyer dashboard.
Future<bool> skipLawyerOnboardingToDashboard(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Skip for now?',
          style: AppTypography.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'You can set availability, fees and optional documents later from your profile.',
          style: AppTypography.inter(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue setup'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go to dashboard'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return false;
  }

  try {
    final response =
        await LawyerProfileRepository.instance.skipOnboardingToDashboard();
    if (!context.mounted) {
      return false;
    }

    await AuthSession.instance.saveNextRoute(response.nextRoute);
    if (!context.mounted) {
      return false;
    }
    final route = LawyerAuthRepository.instance.routeForNextStep(
      response.nextRoute,
    );
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    return true;
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not skip onboarding')),
      );
    }
    return false;
  }
}

/// Whether required docs are uploaded locally (Bar Council + profile photo).
bool canSkipLawyerOnboarding({
  required bool barCertUploaded,
  required bool profilePhotoUploaded,
}) {
  return barCertUploaded && profilePhotoUploaded;
}
