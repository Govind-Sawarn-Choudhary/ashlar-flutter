import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthSectionDivider extends StatelessWidget {
  const AuthSectionDivider({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            color: AppColors.gold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
