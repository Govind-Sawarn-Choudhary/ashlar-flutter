import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Scrollable range calendar — Figma week picker (`7125:5816`).
class LawyerAvailabilityCalendarPicker extends StatefulWidget {
  const LawyerAvailabilityCalendarPicker({
    super.key,
    this.initialRange,
    this.monthsToShow = 12,
  });

  final DateTimeRange? initialRange;
  final int monthsToShow;

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initialRange,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LawyerAvailabilityCalendarPicker(
        initialRange: initialRange,
      ),
    );
  }

  @override
  State<LawyerAvailabilityCalendarPicker> createState() =>
      _LawyerAvailabilityCalendarPickerState();
}

class _LawyerAvailabilityCalendarPickerState
    extends State<LawyerAvailabilityCalendarPicker> {
  static const _dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _headerColor = Color(0xFF808080);
  static const _monthColor = Color(0xFF070707);

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    if (initial != null) {
      _rangeStart = _dateOnly(initial.start);
      _rangeEnd = _dateOnly(initial.end);
      _focusedDay = _rangeStart;
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime? get _normalizedStart {
    if (_rangeStart == null) {
      return null;
    }
    if (_rangeEnd == null) {
      return _rangeStart;
    }
    return _rangeStart!.isBefore(_rangeEnd!) ? _rangeStart : _rangeEnd;
  }

  DateTime? get _normalizedEnd {
    if (_rangeStart == null) {
      return null;
    }
    if (_rangeEnd == null) {
      return _rangeStart;
    }
    return _rangeStart!.isBefore(_rangeEnd!) ? _rangeEnd : _rangeStart;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day) {
    final start = _normalizedStart;
    final end = _normalizedEnd;
    if (start == null || end == null) {
      return false;
    }
    final d = _dateOnly(day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool _isRangeStart(DateTime day) {
    final start = _normalizedStart;
    return start != null && _isSameDay(day, start);
  }

  bool _isRangeEnd(DateTime day) {
    final end = _normalizedEnd;
    return end != null && _isSameDay(day, end);
  }

  void _onDayTap(DateTime day) {
    setState(() {
      _focusedDay = day;

      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = day;
        _rangeEnd = null;
        return;
      }

      _rangeEnd = day;
    });
  }

  void _onDone() {
    final start = _normalizedStart;
    if (start == null) {
      Navigator.of(context).pop();
      return;
    }
    final end = _normalizedEnd ?? start;
    Navigator.of(context).pop(DateTimeRange(start: start, end: end));
  }

  List<DateTime> _months() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    return List.generate(
      widget.monthsToShow,
      (i) => DateTime(first.year, first.month + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select calender week',
                      style: AppTypography.inter(
                        color: _monthColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _headerColor, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final label in _dayHeaders)
                    Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: AppTypography.inter(
                            color: _headerColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                itemCount: _months().length,
                itemBuilder: (context, index) {
                  return _MonthGrid(
                    month: _months()[index],
                    monthLabel:
                        '${_monthNames[_months()[index].month - 1]} ${_months()[index].year}',
                    isInRange: _isInRange,
                    isRangeStart: _isRangeStart,
                    isRangeEnd: _isRangeEnd,
                    isFocused: (day) =>
                        _focusedDay != null && _isSameDay(day, _focusedDay!),
                    onDayTap: _onDayTap,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _normalizedStart != null ? _onDone : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    disabledBackgroundColor: const Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: AppTypography.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1,
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.monthLabel,
    required this.isInRange,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isFocused,
    required this.onDayTap,
  });

  final DateTime month;
  final String monthLabel;
  final bool Function(DateTime day) isInRange;
  final bool Function(DateTime day) isRangeStart;
  final bool Function(DateTime day) isRangeEnd;
  final bool Function(DateTime day) isFocused;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              monthLabel,
              style: AppTypography.inter(
                color: const Color(0xFF070707),
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: _buildCell(row, col, leadingEmpty, daysInMonth),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, int leadingEmpty, int daysInMonth) {
    final index = row * 7 + col;
    final dayNumber = index - leadingEmpty + 1;

    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 40);
    }

    final day = DateTime(month.year, month.month, dayNumber);
    final inRange = isInRange(day);
    final isStart = isRangeStart(day);
    final isEnd = isRangeEnd(day);
    final isSingleDay = isStart && isEnd;
    final focused = isFocused(day) && !inRange;

    return _CalendarDayCell(
      day: dayNumber,
      inRange: inRange && !isSingleDay,
      isStart: isStart,
      isEnd: isEnd,
      isSingleDay: isSingleDay,
      showFocusRing: focused,
      onTap: () => onDayTap(day),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.inRange,
    required this.isStart,
    required this.isEnd,
    required this.isSingleDay,
    required this.showFocusRing,
    required this.onTap,
  });

  final int day;
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final bool isSingleDay;
  final bool showFocusRing;
  final VoidCallback onTap;

  static const _rangeFill = Color(0xFFF0E6FF);
  static const _focusRing = Color(0xFF070707);

  @override
  Widget build(BuildContext context) {
    final isEndpoint = isStart || isEnd;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (inRange || isStart || isEnd)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isStart ? 20 : 0,
                    right: isEnd ? 20 : 0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSingleDay ? Colors.transparent : _rangeFill,
                      borderRadius: BorderRadius.horizontal(
                        left: isStart && !isSingleDay
                            ? const Radius.circular(0)
                            : Radius.zero,
                        right: isEnd && !isSingleDay
                            ? const Radius.circular(0)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
              ),
            if (isEndpoint)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              )
            else if (showFocusRing)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _focusRing, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: AppTypography.inter(
                    color: const Color(0xFF070707),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              )
            else
              Text(
                '$day',
                style: AppTypography.inter(
                  color: const Color(0xFF070707),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Formats a selected date range for the Week field.
String formatAvailabilityDateRange(DateTimeRange range) {
  final start = range.start;
  final end = range.end;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final startLabel =
      '${months[start.month - 1]} ${start.day}, ${start.year}';
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return startLabel;
  }

  if (start.year == end.year && start.month == end.month) {
    return '${months[start.month - 1]} ${start.day} - ${end.day}, ${start.year}';
  }

  if (start.year == end.year) {
    return '${months[start.month - 1]} ${start.day} - '
        '${months[end.month - 1]} ${end.day}, ${start.year}';
  }

  return '$startLabel - ${months[end.month - 1]} ${end.day}, ${end.year}';
}
