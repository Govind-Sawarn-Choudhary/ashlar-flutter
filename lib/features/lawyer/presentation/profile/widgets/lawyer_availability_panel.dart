import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lawyer availability form — clear sections for hours, days, and optional dates.
class LawyerAvailabilityPanel extends StatelessWidget {
  const LawyerAvailabilityPanel({
    super.key,
    required this.selectedDays,
    required this.repeatWeekly,
    required this.selectedWeek,
    required this.fromTime,
    required this.toTime,
    required this.onWeekTap,
    required this.onDayToggled,
    required this.onFromTap,
    required this.onToTap,
    required this.onRepeatChanged,
    this.onClearDateRange,
  });

  final Set<int> selectedDays;
  final bool repeatWeekly;
  final String? selectedWeek;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final VoidCallback onWeekTap;
  final ValueChanged<int> onDayToggled;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final ValueChanged<bool> onRepeatChanged;
  final VoidCallback? onClearDateRange;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _daysBadge {
    if (selectedDays.length == 7) {
      return 'Every day';
    }
    if (selectedDays.isEmpty) {
      return 'Select days';
    }
    return '${selectedDays.length} day${selectedDays.length == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: 'Working hours',
              badge: 'Required',
              badgeColor: const Color(0xFFE8F5E9),
              badgeTextColor: const Color(0xFF2E7D32),
              subtitle: 'Set the time slot when clients can book you.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AvailabilityField(
                    label: 'Start time',
                    value: fromTime != null ? _formatTime(fromTime!) : null,
                    hint: '9:00 AM',
                    onTap: onFromTap,
                    icon: AppAssets.availabilityClockIcon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AvailabilityField(
                    label: 'End time',
                    value: toTime != null ? _formatTime(toTime!) : null,
                    hint: '6:00 PM',
                    onTap: onToTap,
                    icon: AppAssets.availabilityClockIcon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Working days',
              badge: _daysBadge,
              badgeColor: const Color(0xFFFFF8E1),
              badgeTextColor: const Color(0xFF8D6E00),
              subtitle: 'Tap to select one or more days — e.g. Mon, Wed & Fri.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < _days.length; index++)
                  FilterChip(
                    label: Text(_days[index]),
                    selected: selectedDays.contains(index),
                    onSelected: (_) => onDayToggled(index),
                    showCheckmark: true,
                    selectedColor: AppColors.gold,
                    checkmarkColor: Colors.white,
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: AppTypography.inter(
                      color: selectedDays.contains(index)
                          ? Colors.white
                          : const Color(0xFF424242),
                      fontWeight: selectedDays.contains(index)
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: selectedDays.contains(index)
                          ? AppColors.gold
                          : const Color(0xFFE0E0E0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                  ),
              ],
            ),
            if (selectedDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Select at least one day to continue.',
                  style: AppTypography.inter(
                    color: const Color(0xFFD32F2F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Material(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onRepeatChanged(!repeatWeekly),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        repeatWeekly ? Icons.check_circle : Icons.circle_outlined,
                        color: repeatWeekly ? AppColors.gold : const Color(0xFFBDBDBD),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apply to all days of the week',
                              style: AppTypography.inter(
                                color: const Color(0xFF212121),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Quick select Mon–Sun (same as picking all chips)',
                              style: AppTypography.inter(
                                color: const Color(0xFF757575),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: repeatWeekly,
                        onChanged: onRepeatChanged,
                        activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Specific dates',
              badge: 'Optional',
              badgeColor: const Color(0xFFECEFF1),
              badgeTextColor: const Color(0xFF546E7A),
              subtitle:
                  'Limit this schedule to a date range, or skip to keep it open-ended.',
            ),
            const SizedBox(height: 12),
            _AvailabilityField(
              label: 'Date range',
              value: selectedWeek,
              hint: 'Tap to pick start and end dates',
              onTap: onWeekTap,
              icon: AppAssets.availabilityDropdownChevron,
              trailingAction: selectedWeek != null && onClearDateRange != null
                  ? IconButton(
                      onPressed: onClearDateRange,
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E)),
                      tooltip: 'Clear dates',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.subtitle,
  });

  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTypography.inter(
                color: const Color(0xFF212121),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: AppTypography.inter(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.inter(
            color: const Color(0xFF757575),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

class _AvailabilityField extends StatelessWidget {
  const _AvailabilityField({
    required this.label,
    required this.hint,
    required this.onTap,
    required this.icon,
    this.value,
    this.trailingAction,
  });

  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final String icon;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inter(
            color: const Color(0xFF424242),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasValue ? AppColors.gold.withValues(alpha: 0.5) : const Color(0xFFE0E0E0),
                ),
                borderRadius: BorderRadius.circular(10),
                color: hasValue ? const Color(0xFFFFFBF0) : Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? value! : hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          color: hasValue
                              ? const Color(0xFF212121)
                              : const Color(0xFF9E9E9E),
                          fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (trailingAction != null) trailingAction!,
                    SvgPicture.asset(
                      icon,
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9E9E9E),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
