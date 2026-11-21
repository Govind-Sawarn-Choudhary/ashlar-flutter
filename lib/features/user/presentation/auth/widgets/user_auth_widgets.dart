import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class UserAuthLanguages {
  static const options = [
    'English',
    'Hindi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Marathi',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Urdu',
    'Odia',
  ];
}

class UserAuthBackButton extends StatelessWidget {
  const UserAuthBackButton({super.key, required this.onTap, required this.scale});

  final VoidCallback onTap;
  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(scale.s(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scale.s(12)),
        child: SizedBox(
          width: scale.s(44),
          height: scale.s(44),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: scale.s(18),
          ),
        ),
      ),
    );
  }
}

class UserClientBadge extends StatelessWidget {
  const UserClientBadge({super.key, required this.scale, this.compact = false});

  final FigmaScale scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.s(compact ? 8 : 10),
        vertical: scale.s(compact ? 4 : 5),
      ),
      decoration: BoxDecoration(
        color: UserDesignTokens.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(scale.s(20)),
        border: Border.all(color: UserDesignTokens.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.roleSelectUserIcon,
            width: scale.s(compact ? 14 : 16),
            height: scale.s(compact ? 14 : 16),
            fit: BoxFit.contain,
          ),
          SizedBox(width: scale.s(6)),
          Text(
            'Client App',
            style: AppTypography.inter(
              color: UserDesignTokens.gold,
              fontWeight: FontWeight.w700,
              fontSize: scale.fs(compact ? 10 : 11),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class UserAuthDivider extends StatelessWidget {
  const UserAuthDivider({super.key, required this.scale, this.label = 'Secure OTP login'});

  final FigmaScale scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1.5, color: UserDesignTokens.gold)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scale.s(12)),
          child: Text(
            label,
            style: AppTypography.openSans(
              color: UserDesignTokens.gold,
              fontWeight: FontWeight.w600,
              fontSize: scale.fs(15),
            ),
          ),
        ),
        Expanded(child: Container(height: 1.5, color: UserDesignTokens.gold)),
      ],
    );
  }
}

class UserAuthPhoneField extends StatelessWidget {
  const UserAuthPhoneField({
    super.key,
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale.s(12)),
        boxShadow: UserDesignTokens.cardShadow,
      ),
      child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          scrollPadding: EdgeInsets.only(bottom: scale.s(120)),
          style: AppTypography.inter(
            color: const Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: scale.fs(16),
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: 'Mobile number',
            hintStyle: AppTypography.inter(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: scale.fs(16),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: scale.s(14), right: scale.s(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: AppTypography.inter(
                      color: const Color(0xFF212121),
                      fontWeight: FontWeight.w700,
                      fontSize: scale.fs(16),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: scale.s(22),
                    margin: EdgeInsets.only(left: scale.s(10)),
                    color: const Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: scale.s(68)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: scale.s(16),
              horizontal: scale.s(4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide(
                color: UserDesignTokens.gold.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: UserDesignTokens.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: UserDesignTokens.error, width: 1.5),
            ),
            errorStyle: AppTypography.inter(
              color: UserDesignTokens.error,
              fontSize: scale.fs(11),
            ),
            errorMaxLines: 2,
          ),
          validator: validator,
        ),
    );
  }
}

class UserAuthTextField extends StatelessWidget {
  const UserAuthTextField({
    super.key,
    required this.scale,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  final FigmaScale scale;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale.s(12)),
        boxShadow: UserDesignTokens.cardShadow,
      ),
      child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          readOnly: readOnly,
          onTap: onTap,
          scrollPadding: EdgeInsets.only(bottom: scale.s(120)),
          style: AppTypography.inter(
            color: const Color(0xFF212121),
            fontWeight: FontWeight.w500,
            fontSize: scale.fs(16),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.inter(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: scale.fs(16),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: scale.s(16),
              horizontal: scale.s(18),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide(
                color: UserDesignTokens.gold.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: UserDesignTokens.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: UserDesignTokens.error, width: 1.5),
            ),
            errorStyle: AppTypography.inter(
              color: UserDesignTokens.error,
              fontSize: scale.fs(11),
            ),
            errorMaxLines: 2,
          ),
          validator: validator,
        ),
    );
  }
}

Future<String?> showUserLanguagePicker(BuildContext context, {String? selected}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: UserDesignTokens.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Preferred Language',
                    style: AppTypography.inter(
                      color: UserDesignTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: UserDesignTokens.textMuted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: UserAuthLanguages.options.length,
                itemBuilder: (context, index) {
                  final language = UserAuthLanguages.options[index];
                  final isSelected = language == selected;
                  return ListTile(
                    title: Text(
                      language,
                      style: AppTypography.inter(
                        color: isSelected
                            ? UserDesignTokens.gold
                            : UserDesignTokens.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: UserDesignTokens.gold)
                        : null,
                    onTap: () => Navigator.pop(context, language),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

String? validateIndianMobile(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) {
    return 'Enter your mobile number';
  }
  if (phone.length != 10) {
    return 'Enter a valid 10-digit mobile number';
  }
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
    return 'Mobile number must start with 6, 7, 8, or 9';
  }
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email address';
  }
  if (!RegExp(r'^[\w-\.+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validateRequired(String? value, String label) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your $label';
  }
  return null;
}
