import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:flutter/material.dart';

class UserPremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UserPremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: UserDesignTokens.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.inter(
                fontSize: 12,
                color: UserDesignTokens.textMuted,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}

class UserSectionHeader extends StatelessWidget {
  const UserSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: UserDesignTokens.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTypography.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: UserDesignTokens.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: UserDesignTokens.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UserQuickAction extends StatelessWidget {
  const UserQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
        child: Ink(
          decoration: UserDesignTokens.premiumCard(),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: UserDesignTokens.goldSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: UserDesignTokens.gold, size: 22),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesignTokens.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: AppTypography.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: UserDesignTokens.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserLawyerCard extends StatelessWidget {
  const UserLawyerCard({
    super.key,
    required this.lawyer,
    required this.onTap,
    this.onFavourite,
    this.compact = false,
  });

  final UserLawyerSummary lawyer;
  final VoidCallback onTap;
  final VoidCallback? onFavourite;
  final bool compact;

  String? get _lowestFee {
    if (lawyer.fees.isEmpty) {
      return null;
    }
    double? min;
    for (final fee in lawyer.fees) {
      final amount = double.tryParse(fee.amount);
      if (amount != null && amount > 0 && (min == null || amount < min)) {
        min = amount;
      }
    }
    return min == null ? null : '₹${min.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
        child: Ink(
          decoration: UserDesignTokens.premiumCard(),
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              Container(
                width: compact ? 44 : 52,
                height: compact ? 44 : 52,
                decoration: BoxDecoration(
                  gradient: UserDesignTokens.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    lawyer.fullName.isNotEmpty
                        ? lawyer.fullName[0].toUpperCase()
                        : 'L',
                    style: AppTypography.inter(
                      fontSize: compact ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        fontSize: compact ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: UserDesignTokens.textPrimary,
                      ),
                    ),
                    if (lawyer.practiceAreas?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        lawyer.practiceAreas!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: UserDesignTokens.gold,
                        ),
                      ),
                    ],
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (lawyer.location?.isNotEmpty == true)
                            Flexible(
                              child: Text(
                                lawyer.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.inter(
                                  fontSize: 11,
                                  color: UserDesignTokens.textMuted,
                                ),
                              ),
                            ),
                          if (_lowestFee != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'From $_lowestFee',
                              style: AppTypography.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: UserDesignTokens.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onFavourite != null)
                IconButton(
                  onPressed: onFavourite,
                  icon: Icon(
                    lawyer.isFavourite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: lawyer.isFavourite
                        ? UserDesignTokens.gold
                        : UserDesignTokens.textMuted,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: UserDesignTokens.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserEmptyState extends StatelessWidget {
  const UserEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: UserDesignTokens.goldSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: UserDesignTokens.gold),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: UserDesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 14,
                height: 1.5,
                color: UserDesignTokens.textMuted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: UserDesignTokens.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UserWalletChip extends StatelessWidget {
  const UserWalletChip({
    super.key,
    required this.balance,
    required this.onTap,
  });

  final double balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: UserDesignTokens.goldGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                '₹${balance.toStringAsFixed(0)}',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark-themed labeled field for profile/settings forms.
class UserPremiumFormField extends StatelessWidget {
  const UserPremiumFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: UserDesignTokens.goldSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: UserDesignTokens.gold),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: UserDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          scrollPadding: const EdgeInsets.only(bottom: 120),
          style: AppTypography.inter(
            color: UserDesignTokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: UserDesignTokens.gold,
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: AppTypography.inter(
              color: UserDesignTokens.textMuted,
              fontSize: 15,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: UserDesignTokens.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
              borderSide: const BorderSide(color: UserDesignTokens.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
              borderSide: const BorderSide(color: UserDesignTokens.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
              borderSide: BorderSide(
                color: UserDesignTokens.gold.withValues(alpha: 0.85),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
              borderSide: const BorderSide(color: UserDesignTokens.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
              borderSide: const BorderSide(color: UserDesignTokens.error, width: 1.5),
            ),
            errorStyle: AppTypography.inter(
              color: UserDesignTokens.error,
              fontSize: 11,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class UserPremiumBottomBar extends StatelessWidget {
  const UserPremiumBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.loading = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: UserDesignTokens.background.withValues(alpha: 0.96),
          border: const Border(
            top: BorderSide(color: UserDesignTokens.cardBorder),
          ),
        ),
        child: Row(
        children: [
          if (secondaryLabel != null && onSecondary != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: loading ? null : onSecondary,
                style: OutlinedButton.styleFrom(
                  foregroundColor: UserDesignTokens.textPrimary,
                  side: BorderSide(
                    color: UserDesignTokens.gold.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  secondaryLabel!,
                  style: AppTypography.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: secondaryLabel != null ? 2 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: loading ? null : UserDesignTokens.goldGradient,
                color: loading ? UserDesignTokens.gold.withValues(alpha: 0.4) : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: loading
                    ? null
                    : [
                        BoxShadow(
                          color: UserDesignTokens.gold.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: loading ? null : onPrimary,
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              primaryLabel,
                              style: AppTypography.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class UserPremiumScaffold extends StatelessWidget {
  const UserPremiumScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomBar,
    this.bottomPadding = 0,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12121A), UserDesignTokens.background],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomBar,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: bottomBar == null,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: body,
          ),
        ),
      ),
    );
  }
}
