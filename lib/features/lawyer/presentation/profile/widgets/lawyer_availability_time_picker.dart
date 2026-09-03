import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Wheel time picker — Figma `7125:6027`.
class LawyerAvailabilityTimePicker extends StatefulWidget {
  const LawyerAvailabilityTimePicker({
    super.key,
    this.initialTime,
  });

  final TimeOfDay? initialTime;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => LawyerAvailabilityTimePicker(
        initialTime: initialTime,
      ),
    );
  }

  @override
  State<LawyerAvailabilityTimePicker> createState() =>
      _LawyerAvailabilityTimePickerState();
}

class _LawyerAvailabilityTimePickerState
    extends State<LawyerAvailabilityTimePicker> {
  static const _lineColor = Color(0xFFE0E0E0);
  static const _titleColor = Color(0xFF070707);
  static const itemExtent = 44.0;
  static const _wheelHeight = 220.0;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _hourIndex;
  late int _minuteIndex;
  late int _periodIndex;

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime ?? TimeOfDay.now();
    _hourIndex = _hourIndexFromTime(time);
    _minuteIndex = time.minute;
    _periodIndex = time.period == DayPeriod.am ? 0 : 1;

    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
    _periodController = FixedExtentScrollController(initialItem: _periodIndex);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  int _hourIndexFromTime(TimeOfDay time) {
    final displayHour =
        time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return displayHour - 1;
  }

  TimeOfDay _buildTime() {
    final displayHour = _hourIndex + 1;
    final minute = _minuteIndex;
    final isPm = _periodIndex == 1;

    final hour24 = isPm
        ? (displayHour == 12 ? 12 : displayHour + 12)
        : (displayHour == 12 ? 0 : displayHour);

    return TimeOfDay(hour: hour24, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select time',
              style: AppTypography.inter(
                color: _titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: _wheelHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TimeWheel(
                          controller: _hourController,
                          itemCount: 12,
                          selectedIndex: _hourIndex,
                          labelBuilder: (index) =>
                              (index + 1).toString().padLeft(2, '0'),
                          onSelectedItemChanged: (index) =>
                              setState(() => _hourIndex = index),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                        child: Center(
                          child: Text(
                            ':',
                            style: AppTypography.inter(
                              color: _titleColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _TimeWheel(
                          controller: _minuteController,
                          itemCount: 60,
                          selectedIndex: _minuteIndex,
                          labelBuilder: (index) =>
                              index.toString().padLeft(2, '0'),
                          onSelectedItemChanged: (index) =>
                              setState(() => _minuteIndex = index),
                        ),
                      ),
                      Expanded(
                        child: _TimeWheel(
                          controller: _periodController,
                          itemCount: 2,
                          selectedIndex: _periodIndex,
                          labelBuilder: (index) => index == 0 ? 'AM' : 'PM',
                          onSelectedItemChanged: (index) =>
                              setState(() => _periodIndex = index),
                        ),
                      ),
                    ],
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 1, color: _lineColor),
                        SizedBox(height: itemExtent - 2),
                        Container(height: 1, color: _lineColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilledActionButton(
                    label: 'Save',
                    onTap: () => Navigator.of(context).pop(_buildTime()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.labelBuilder,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  static const _mutedColor = Color(0xFFA0A0A0);
  static const _titleColor = Color(0xFF070707);

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _LawyerAvailabilityTimePickerState.itemExtent,
      diameterRatio: 1.35,
      perspective: 0.003,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: Text(
              labelBuilder(index),
              style: AppTypography.inter(
                color: isSelected ? _titleColor : _mutedColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: isSelected ? 18 : 16,
                height: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: const Color(0xFF808080),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            color: const Color(0xFF808080),
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1,
          ),
        ),
      ),
    );
  }
}
