import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AvailabilityScheduleMode { same, custom }

/// Premium availability form — same hours or custom per-day schedules.
class LawyerAvailabilityPanel extends StatelessWidget {
  const LawyerAvailabilityPanel({
    super.key,
    required this.scheduleMode,
    required this.selectedDays,
    required this.selectedWeek,
    required this.fromTime,
    required this.toTime,
    required this.daySchedules,
    required this.onScheduleModeChanged,
    required this.onPresetSelected,
    required this.onDayToggled,
    required this.onWeekTap,
    required this.onFromTap,
    required this.onToTap,
    required this.onCustomFromTap,
    required this.onCustomToTap,
    this.onClearDateRange,
  });

  final AvailabilityScheduleMode scheduleMode;
  final Set<int> selectedDays;
  final String? selectedWeek;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final Map<int, ({TimeOfDay? from, TimeOfDay? to})> daySchedules;
  final ValueChanged<AvailabilityScheduleMode> onScheduleModeChanged;
  final ValueChanged<Set<int>> onPresetSelected;
  final ValueChanged<int> onDayToggled;
  final VoidCallback onWeekTap;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final ValueChanged<int> onCustomFromTap;
  final ValueChanged<int> onCustomToTap;
  final VoidCallback? onClearDateRange;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _daysBadge {
    if (selectedDays.length == 7) {
      return 'Every day';
    }
    if (selectedDays.isEmpty) {
      return 'Pick days';
    }
    return LawyerProfileHelpers.formatSelectedDaysLabel(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScheduleModeSelector(
          mode: scheduleMode,
          onChanged: onScheduleModeChanged,
        ),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'Working days',
                badge: _daysBadge,
                badgeColor: const Color(0xFFFFF8E1),
                badgeTextColor: const Color(0xFF8D6E00),
                subtitle: scheduleMode == AvailabilityScheduleMode.same
                    ? 'Choose days that share the same consultation hours.'
                    : 'Choose days — you can set different hours for each day.',
              ),
              const SizedBox(height: 12),
              _PresetRow(
                selectedDays: selectedDays,
                onPresetSelected: onPresetSelected,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < _days.length; index++)
                    _DayChip(
                      label: _days[index],
                      selected: selectedDays.contains(index),
                      onTap: () => onDayToggled(index),
                    ),
                ],
              ),
              if (selectedDays.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Select at least one day to continue.',
                    style: AppTypography.inter(
                      color: const Color(0xFFD32F2F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (scheduleMode == AvailabilityScheduleMode.same)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'Same hours every day',
                  badge: 'Recommended',
                  badgeColor: const Color(0xFFE8F5E9),
                  badgeTextColor: const Color(0xFF2E7D32),
                  subtitle:
                      'Clients can book any selected day within this time window — e.g. Mon–Sat, 9 AM to 6 PM.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _AvailabilityField(
                        label: 'Start time',
                        value: fromTime != null
                            ? LawyerProfileHelpers.formatTimeLabel(fromTime!)
                            : null,
                        hint: '9:00 AM',
                        onTap: onFromTap,
                        icon: AppAssets.availabilityClockIcon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AvailabilityField(
                        label: 'End time',
                        value: toTime != null
                            ? LawyerProfileHelpers.formatTimeLabel(toTime!)
                            : null,
                        hint: '6:00 PM',
                        onTap: onToTap,
                        icon: AppAssets.availabilityClockIcon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  title: 'Custom hours per day',
                  badge: '${selectedDays.length} day${selectedDays.length == 1 ? '' : 's'}',
                  badgeColor: const Color(0xFFE3F2FD),
                  badgeTextColor: const Color(0xFF1565C0),
                  subtitle:
                      'Set different start and end times for each day — useful when your schedule varies.',
                ),
                const SizedBox(height: 12),
                if (selectedDays.isEmpty)
                  Text(
                    'Select days above to configure custom times.',
                    style: AppTypography.inter(
                      color: const Color(0xFF757575),
                      fontSize: 13,
                    ),
                  )
                else
                  for (final day in (selectedDays.toList()..sort()))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CustomDayRow(
                        dayLabel: _days[day],
                        fromTime: daySchedules[day]?.from,
                        toTime: daySchedules[day]?.to,
                        onFromTap: () => onCustomFromTap(day),
                        onToTap: () => onCustomToTap(day),
                      ),
                    ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'Date range',
                badge: 'Optional',
                badgeColor: const Color(0xFFECEFF1),
                badgeTextColor: const Color(0xFF546E7A),
                subtitle:
                    'Limit availability to a specific week or month. Leave empty for ongoing weekly schedule.',
              ),
              const SizedBox(height: 12),
              _AvailabilityField(
                label: 'Active period',
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
        const SizedBox(height: 14),
        _ClientPreviewCard(
          scheduleMode: scheduleMode,
          selectedDays: selectedDays,
          fromTime: fromTime,
          toTime: toTime,
          daySchedules: daySchedules,
        ),
      ],
    );
  }
}

class _ScheduleModeSelector extends StatelessWidget {
  const _ScheduleModeSelector({
    required this.mode,
    required this.onChanged,
  });

  final AvailabilityScheduleMode mode;
  final ValueChanged<AvailabilityScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            icon: Icons.schedule_rounded,
            title: 'Same time',
            subtitle: 'Mon–Sat with one slot',
            selected: mode == AvailabilityScheduleMode.same,
            onTap: () => onChanged(AvailabilityScheduleMode.same),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeCard(
            icon: Icons.tune_rounded,
            title: 'Custom time',
            subtitle: 'Different hours per day',
            selected: mode == AvailabilityScheduleMode.custom,
            onTap: () => onChanged(AvailabilityScheduleMode.custom),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.gold.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.gold : Colors.white24,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.gold : Colors.white70,
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.inter(
                  color: selected ? AppColors.gold : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.inter(
                  color: selected ? Colors.white70 : Colors.white54,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.selectedDays,
    required this.onPresetSelected,
  });

  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onPresetSelected;

  static const _weekdays = {0, 1, 2, 3, 4};
  static const _monToSat = {0, 1, 2, 3, 4, 5};
  static const _allDays = {0, 1, 2, 3, 4, 5, 6};

  bool _matches(Set<int> preset) =>
      selectedDays.length == preset.length && selectedDays.containsAll(preset);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PresetChip(
          label: 'Mon–Fri',
          selected: _matches(_weekdays),
          onTap: () => onPresetSelected(_weekdays),
        ),
        _PresetChip(
          label: 'Mon–Sat',
          selected: _matches(_monToSat),
          onTap: () => onPresetSelected(_monToSat),
        ),
        _PresetChip(
          label: 'All days',
          selected: _matches(_allDays),
          onTap: () => onPresetSelected(_allDays),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? AppColors.gold.withValues(alpha: 0.18) : const Color(0xFFF5F5F5),
      labelStyle: AppTypography.inter(
        color: selected ? const Color(0xFF6D4C00) : const Color(0xFF424242),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? AppColors.gold : const Color(0xFFE0E0E0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: true,
      selectedColor: AppColors.gold,
      checkmarkColor: Colors.white,
      backgroundColor: const Color(0xFFF5F5F5),
      labelStyle: AppTypography.inter(
        color: selected ? Colors.white : const Color(0xFF424242),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: selected ? AppColors.gold : const Color(0xFFE0E0E0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _CustomDayRow extends StatelessWidget {
  const _CustomDayRow({
    required this.dayLabel,
    required this.fromTime,
    required this.toTime,
    required this.onFromTap,
    required this.onToTap,
  });

  final String dayLabel;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  @override
  Widget build(BuildContext context) {
    final complete = fromTime != null && toTime != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: complete ? const Color(0xFFF9FBFF) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? AppColors.gold.withValues(alpha: 0.35)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dayLabel,
                  style: AppTypography.inter(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  complete
                      ? '${LawyerProfileHelpers.formatTimeLabel(fromTime!)} – ${LawyerProfileHelpers.formatTimeLabel(toTime!)}'
                      : 'Set hours for $dayLabel',
                  style: AppTypography.inter(
                    color: const Color(0xFF212121),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (complete)
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniTimeButton(
                  label: 'Start',
                  value: fromTime != null
                      ? LawyerProfileHelpers.formatTimeLabel(fromTime!)
                      : 'Pick',
                  onTap: onFromTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniTimeButton(
                  label: 'End',
                  value: toTime != null
                      ? LawyerProfileHelpers.formatTimeLabel(toTime!)
                      : 'Pick',
                  onTap: onToTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTimeButton extends StatelessWidget {
  const _MiniTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  color: const Color(0xFF757575),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.inter(
                  color: const Color(0xFF212121),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientPreviewCard extends StatelessWidget {
  const _ClientPreviewCard({
    required this.scheduleMode,
    required this.selectedDays,
    required this.fromTime,
    required this.toTime,
    required this.daySchedules,
  });

  final AvailabilityScheduleMode scheduleMode;
  final Set<int> selectedDays;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final Map<int, ({TimeOfDay? from, TimeOfDay? to})> daySchedules;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'What clients will see',
                style: AppTypography.inter(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (selectedDays.isEmpty)
            Text(
              'Your schedule preview will appear here.',
              style: AppTypography.inter(color: Colors.white70, fontSize: 12),
            )
          else if (scheduleMode == AvailabilityScheduleMode.same &&
              fromTime != null &&
              toTime != null)
            Text(
              '${LawyerProfileHelpers.formatSelectedDaysLabel(selectedDays)} · ${LawyerProfileHelpers.formatTimeLabel(fromTime!)} – ${LawyerProfileHelpers.formatTimeLabel(toTime!)}',
              style: AppTypography.inter(
                color: Colors.white,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            )
          else if (scheduleMode == AvailabilityScheduleMode.custom)
            for (final day in (selectedDays.toList()..sort()))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  daySchedules[day]?.from != null && daySchedules[day]?.to != null
                      ? '${_days[day]}: ${LawyerProfileHelpers.formatTimeLabel(daySchedules[day]!.from!)} – ${LawyerProfileHelpers.formatTimeLabel(daySchedules[day]!.to!)}'
                      : '${_days[day]}: Set times',
                  style: AppTypography.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              )
          else
            Text(
              '${LawyerProfileHelpers.formatSelectedDaysLabel(selectedDays)} · Set your hours above',
              style: AppTypography.inter(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: child,
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
            Expanded(
              child: Text(
                title,
                style: AppTypography.inter(
                  color: const Color(0xFF212121),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
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
                  color: hasValue
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : const Color(0xFFE0E0E0),
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
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
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
