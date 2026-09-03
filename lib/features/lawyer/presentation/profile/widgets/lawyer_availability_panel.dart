import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// White form card — Figma `7125:5791` / inner `7125:5792`.
class LawyerAvailabilityPanel extends StatelessWidget {
  const LawyerAvailabilityPanel({
    super.key,
    required this.scale,
    required this.selectedDay,
    required this.repeatWeekly,
    required this.selectedWeek,
    required this.fromTime,
    required this.toTime,
    required this.onWeekTap,
    required this.onDaySelected,
    required this.onFromTap,
    required this.onToTap,
    required this.onRepeatChanged,
  });

  final FigmaScale scale;
  final int selectedDay;
  final bool repeatWeekly;
  final String? selectedWeek;
  final TimeOfDay? fromTime;
  final TimeOfDay? toTime;
  final VoidCallback onWeekTap;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final ValueChanged<bool> onRepeatChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.s(_Tokens.panelRadius)),
      ),
      child: Padding(
        padding: EdgeInsets.all(scale.s(_Tokens.panelPad)),
        child: SizedBox(
          width: scale.s(_Tokens.innerW),
          height: scale.s(_Tokens.innerH),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: scale.s(_Tokens.innerW),
                height: scale.s(_Tokens.weekH),
                child: _AvailabilityField(
                  scale: scale,
                  label: 'Week',
                  value: selectedWeek,
                  hint: 'Select calender week',
                  onTap: onWeekTap,
                  trailing: _FigmaSvgIcon(
                    scale: scale,
                    asset: AppAssets.availabilityDropdownChevron,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: scale.s(_Tokens.dayTop),
                width: scale.s(_Tokens.innerW),
                height: scale.s(_Tokens.dayH),
                child: _DayTabsSection(
                  scale: scale,
                  selectedDay: selectedDay,
                  onDaySelected: onDaySelected,
                ),
              ),
              Positioned(
                left: 0,
                top: scale.s(_Tokens.timeTop),
                width: scale.s(_Tokens.innerW),
                height: scale.s(_Tokens.timeH),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: scale.s(_Tokens.halfFieldW),
                      child: _AvailabilityField(
                        scale: scale,
                        label: 'From',
                        value: fromTime != null ? _formatTime(fromTime!) : null,
                        hint: 'Available from',
                        onTap: onFromTap,
                        trailing: _FigmaSvgIcon(
                          scale: scale,
                          asset: AppAssets.availabilityClockIcon,
                        ),
                      ),
                    ),
                    Positioned(
                      left: scale.s(_Tokens.toLeft),
                      top: 0,
                      width: scale.s(_Tokens.halfFieldW),
                      child: _AvailabilityField(
                        scale: scale,
                        label: 'To',
                        value: toTime != null ? _formatTime(toTime!) : null,
                        hint: 'Available till',
                        onTap: onToTap,
                        trailing: _FigmaSvgIcon(
                          scale: scale,
                          asset: AppAssets.availabilityClockIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: scale.s(_Tokens.repeatTop),
                width: scale.s(_Tokens.innerW),
                height: scale.s(_Tokens.repeatH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(scale, 'Repeat'),
                    SizedBox(height: scale.s(_Tokens.labelGap)),
                    SizedBox(
                      height: scale.s(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AvailabilityCheckbox(
                            scale: scale,
                            value: repeatWeekly,
                            onChanged: onRepeatChanged,
                          ),
                          SizedBox(width: scale.s(8)),
                          Padding(
                            padding: EdgeInsets.only(top: scale.s(2)),
                            child: Text(
                              'Repeat this for all days of the week.',
                              style: _bodyMuted(scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _Tokens {
  static const panelRadius = 8.0;
  static const panelPad = 12.0;
  static const innerW = 305.0;
  static const innerH = 328.0;

  static const weekH = 75.0;
  static const dayTop = 91.0;
  static const dayH = 83.0;
  static const timeTop = 190.0;
  static const timeH = 75.0;
  static const repeatTop = 281.0;
  static const repeatH = 47.0;

  static const halfFieldW = 148.5;
  static const toLeft = 156.5;

  static const labelH = 15.0;
  static const labelGap = 8.0;
  static const fieldH = 52.0;
  static const fieldPad = 16.0;
  static const fieldRadius = 12.0;

  static const borderColor = Color(0xFFE6E6E6);
  static const labelColor = Color(0xFF070707);
  static const placeholderColor = Color(0xFF808080);

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const dayTabWidths = [47.0, 46.0, 46.0, 46.0, 46.0, 46.0, 46.0];
  static const dayTabLefts = [
    0.0,
    38.667,
    76.334,
    114.001,
    151.668,
    189.335,
    227.002,
  ];
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

TextStyle _labelStyle(FigmaScale scale) => AppTypography.inter(
      color: _Tokens.labelColor,
      fontWeight: FontWeight.w700,
      fontSize: scale.fs(12),
      height: 1,
    );

TextStyle _bodyMuted(FigmaScale scale) => AppTypography.inter(
      color: _Tokens.placeholderColor,
      fontWeight: FontWeight.w400,
      fontSize: scale.fs(14),
      height: 20 / 14,
    );

Widget _fieldLabel(FigmaScale scale, String text) {
  return SizedBox(
    height: scale.s(_Tokens.labelH),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: _labelStyle(scale)),
    ),
  );
}

class _AvailabilityField extends StatelessWidget {
  const _AvailabilityField({
    required this.scale,
    required this.label,
    required this.hint,
    required this.onTap,
    required this.trailing,
    this.value,
  });

  final FigmaScale scale;
  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(scale, label),
        SizedBox(height: scale.s(_Tokens.labelGap)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(scale.s(_Tokens.fieldRadius)),
            child: Ink(
              height: scale.s(_Tokens.fieldH),
              decoration: BoxDecoration(
                border: Border.all(color: _Tokens.borderColor),
                borderRadius:
                    BorderRadius.circular(scale.s(_Tokens.fieldRadius)),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: scale.s(_Tokens.fieldPad)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? value! : hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          color: hasValue
                              ? _Tokens.labelColor
                              : _Tokens.placeholderColor,
                          fontWeight: FontWeight.w400,
                          fontSize: scale.fs(14),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    SizedBox(width: scale.s(8)),
                    trailing,
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

class _DayTabsSection extends StatelessWidget {
  const _DayTabsSection({
    required this.scale,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final FigmaScale scale;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(scale, 'Day'),
        SizedBox(height: scale.s(_Tokens.labelGap)),
        SizedBox(
          width: scale.s(_Tokens.innerW),
          height: scale.s(60),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _Tokens.borderColor),
              borderRadius: BorderRadius.circular(scale.s(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scale.s(16),
                vertical: scale.s(8),
              ),
              child: SizedBox(
                height: scale.s(44),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < _Tokens.days.length; i++)
                      Positioned(
                        left: scale.s(_Tokens.dayTabLefts[i]),
                        top: 0,
                        child: _DayTab(
                          scale: scale,
                          label: _Tokens.days[i],
                          width: _Tokens.dayTabWidths[i],
                          isSelected: i == selectedDay,
                          onTap: () => onDaySelected(i),
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

class _DayTab extends StatelessWidget {
  const _DayTab({
    required this.scale,
    required this.label,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  final FigmaScale scale;
  final String label;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: scale.s(width),
        height: scale.s(44),
        child: Column(
          children: [
            SizedBox(
              height: scale.s(36),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.inter(
                    color: isSelected
                        ? _Tokens.labelColor
                        : _Tokens.placeholderColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: scale.fs(14),
                    height: isSelected ? 1.0 : 20 / 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: scale.s(4)),
            Container(
              width: scale.s(isSelected ? width : 24),
              height: scale.s(4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(scale.s(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityCheckbox extends StatelessWidget {
  const _AvailabilityCheckbox({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  final FigmaScale scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: scale.s(24),
        height: scale.s(24),
        decoration: BoxDecoration(
          color: value ? AppColors.gold : Colors.transparent,
          border: Border.all(
            color: _Tokens.borderColor,
            width: scale.s(1.5),
          ),
          borderRadius: BorderRadius.circular(scale.s(6)),
        ),
        child: value
            ? Icon(Icons.check, size: scale.s(14), color: Colors.white)
            : null,
      ),
    );
  }
}

class _FigmaSvgIcon extends StatelessWidget {
  const _FigmaSvgIcon({required this.scale, required this.asset});

  final FigmaScale scale;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final size = scale.s(12);
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
