import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_onboarding_skip.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_calendar_picker.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_panel.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_time_picker.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';

/// Lawyer onboarding step 3 — set consultation availability.
enum LawyerSelectAvailabilityMode { registration, update }

class LawyerSelectAvailabilityScreen extends StatefulWidget {
  const LawyerSelectAvailabilityScreen({
    super.key,
    this.mode = LawyerSelectAvailabilityMode.registration,
  });

  final LawyerSelectAvailabilityMode mode;

  @override
  State<LawyerSelectAvailabilityScreen> createState() =>
      _LawyerSelectAvailabilityScreenState();
}

class _LawyerSelectAvailabilityScreenState
    extends State<LawyerSelectAvailabilityScreen> {
  static const _allDays = {0, 1, 2, 3, 4, 5, 6};

  AvailabilityScheduleMode _scheduleMode = AvailabilityScheduleMode.same;
  Set<int> _selectedDays = _LawyerSelectAvailabilityScreenState._monToSat;
  DateTimeRange? _selectedWeekRange;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  Map<int, ({TimeOfDay? from, TimeOfDay? to})> _daySchedules = {};
  bool _isSaving = false;
  bool _loading = true;

  static const _monToSat = {0, 1, 2, 3, 4, 5};

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final availability = response.availability;
      if (availability != null) {
        _selectedDays = LawyerProfileHelpers.parseSelectedDays(availability);
        _selectedWeekRange = LawyerProfileHelpers.parseWeekRange(availability);
        _fromTime = LawyerProfileHelpers.parseTimeLabel(availability.fromTime);
        _toTime = LawyerProfileHelpers.parseTimeLabel(availability.toTime);
        _scheduleMode = availability.isCustomSchedule
            ? AvailabilityScheduleMode.custom
            : AvailabilityScheduleMode.same;

        final parsedSchedules = LawyerProfileHelpers.parseDaySchedules(availability);
        _daySchedules = {
          for (final entry in parsedSchedules.entries)
            entry.key: (from: entry.value.from, to: entry.value.to),
        };
      }
    } catch (_) {
      // Fresh onboarding keeps defaults.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickWeek() async {
    final picked = await LawyerAvailabilityCalendarPicker.show(
      context,
      initialRange: _selectedWeekRange,
    );

    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selectedWeekRange = picked);
  }

  Future<void> _pickTime({
    required bool isFrom,
    int? day,
  }) async {
    TimeOfDay initial;
    if (day != null) {
      final schedule = _daySchedules[day];
      initial = (isFrom ? schedule?.from : schedule?.to) ??
          _fromTime ??
          const TimeOfDay(hour: 9, minute: 0);
    } else {
      initial = (isFrom ? _fromTime : _toTime) ?? const TimeOfDay(hour: 9, minute: 0);
    }

    final picked = await LawyerAvailabilityTimePicker.show(
      context,
      initialTime: initial,
      title: isFrom ? 'Start time' : 'End time',
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      if (day != null) {
        final current = _daySchedules[day] ?? (from: null, to: null);
        _daySchedules[day] = isFrom
            ? (from: picked, to: current.to)
            : (from: current.from, to: picked);
      } else if (isFrom) {
        _fromTime = picked;
      } else {
        _toTime = picked;
      }
    });
  }

  void _applyPreset(Set<int> days) {
    setState(() {
      _selectedDays = Set<int>.from(days);
      _seedCustomSchedulesForSelectedDays();
    });
  }

  void _toggleDay(int index) {
    setState(() {
      final next = Set<int>.from(_selectedDays);
      if (next.contains(index)) {
        next.remove(index);
        _daySchedules.remove(index);
      } else {
        next.add(index);
        _daySchedules[index] = (
          from: _fromTime ?? const TimeOfDay(hour: 9, minute: 0),
          to: _toTime ?? const TimeOfDay(hour: 18, minute: 0),
        );
      }
      _selectedDays = next;
    });
  }

  void _onScheduleModeChanged(AvailabilityScheduleMode mode) {
    setState(() {
      _scheduleMode = mode;
      if (mode == AvailabilityScheduleMode.custom) {
        _seedCustomSchedulesForSelectedDays();
      }
    });
  }

  void _seedCustomSchedulesForSelectedDays() {
    final seeded = Map<int, ({TimeOfDay? from, TimeOfDay? to})>.from(_daySchedules);
    for (final day in _selectedDays) {
      seeded.putIfAbsent(
        day,
        () => (
          from: _fromTime ?? const TimeOfDay(hour: 9, minute: 0),
          to: _toTime ?? const TimeOfDay(hour: 18, minute: 0),
        ),
      );
    }
    _daySchedules = seeded;
  }

  bool get _repeatWeekly => _selectedDays.length == _allDays.length;

  Map<int, ({TimeOfDay from, TimeOfDay to})> _completedDaySchedules() {
    final completed = <int, ({TimeOfDay from, TimeOfDay to})>{};
    for (final day in _selectedDays) {
      final schedule = _daySchedules[day];
      if (schedule?.from != null &&
          schedule?.to != null &&
          LawyerProfileHelpers.isValidTimeRange(schedule!.from, schedule.to)) {
        completed[day] = (from: schedule.from!, to: schedule.to!);
      }
    }
    return completed;
  }

  Future<void> _onContinue() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one working day.')),
      );
      return;
    }

    if (_scheduleMode == AvailabilityScheduleMode.same) {
      if (_fromTime == null || _toTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set your start and end time.')),
        );
        return;
      }
      if (!LawyerProfileHelpers.isValidTimeRange(_fromTime, _toTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
        );
        return;
      }
    } else {
      final completed = _completedDaySchedules();
      if (completed.length != _selectedDays.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set valid start and end times for every selected day.'),
          ),
        );
        return;
      }
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final completedSchedules = _completedDaySchedules();
      final response = await LawyerProfileRepository.instance.saveAvailability(
        selectedDays: _selectedDays,
        repeatWeekly: _repeatWeekly,
        scheduleMode: _scheduleMode == AvailabilityScheduleMode.custom ? 'custom' : 'same',
        weekRange: _selectedWeekRange,
        fromTime: _fromTime,
        toTime: _toTime,
        daySchedules: _scheduleMode == AvailabilityScheduleMode.custom
            ? completedSchedules
            : null,
      );

      if (!mounted) {
        return;
      }

      if (widget.mode == LawyerSelectAvailabilityMode.update) {
        Navigator.of(context).pop(true);
        return;
      }

      final route = LawyerAuthRepository.instance.routeForNextStep(
        response.nextRoute,
      );
      Navigator.of(context).pushReplacementNamed(route);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/role-select',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isUpdate = widget.mode == LawyerSelectAvailabilityMode.update;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : FigmaScreenCanvas(
              builder: (context, s) {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isUpdate)
                        Padding(
                          padding: EdgeInsets.fromLTRB(s.s(8), s.s(4), s.s(8), 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.only(left: s.s(7)),
                                  child: Image.asset(
                                    AppAssets.walletBackButton,
                                    width: s.s(40),
                                    height: s.s(40),
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Update Availability',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.inter(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                    fontSize: s.fs(18),
                                  ),
                                ),
                              ),
                              SizedBox(width: s.s(47)),
                            ],
                          ),
                        ),
                      if (!isUpdate) ...[
                        SizedBox(height: s.s(8)),
                        LawyerSetupStepBar(
                          scale: s,
                          activeStep: 2,
                          showProgressTracks: true,
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUpdate)
                              Text(
                                'Set Your Availability',
                                style: AppTypography.inter(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: s.fs(20),
                                ),
                              ),
                            if (!isUpdate) SizedBox(height: s.s(6)),
                            Text(
                              isUpdate
                                  ? 'Update when clients can book you. Changes save when you tap Save.'
                                  : 'Step 3 of 3 — Clients can book on your selected days. Use same hours for Mon–Sat, or set custom times per day.',
                              style: AppTypography.inter(
                                color: Colors.white70,
                                fontSize: s.fs(13),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(s.s(16), s.s(16), s.s(16), s.s(8)),
                          child: LawyerAvailabilityPanel(
                            scheduleMode: _scheduleMode,
                            selectedDays: _selectedDays,
                            selectedWeek: _selectedWeekRange != null
                                ? formatAvailabilityDateRange(_selectedWeekRange!)
                                : null,
                            fromTime: _fromTime,
                            toTime: _toTime,
                            daySchedules: _daySchedules,
                            onScheduleModeChanged: _onScheduleModeChanged,
                            onPresetSelected: _applyPreset,
                            onDayToggled: _toggleDay,
                            onWeekTap: _pickWeek,
                            onFromTap: () => _pickTime(isFrom: true),
                            onToTap: () => _pickTime(isFrom: false),
                            onCustomFromTap: (day) => _pickTime(isFrom: true, day: day),
                            onCustomToTap: (day) => _pickTime(isFrom: false, day: day),
                            onClearDateRange: () =>
                                setState(() => _selectedWeekRange = null),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          s.s(18),
                          s.s(8),
                          s.s(18),
                          s.s(12) + (keyboardInset > 0 ? keyboardInset : 0),
                        ),
                        child: Opacity(
                          opacity: _isSaving ? 0.55 : 1,
                          child: IgnorePointer(
                            ignoring: _isSaving,
                            child: SizedBox(
                              width: double.infinity,
                              height: s.s(52),
                              child: GoldActionButton(
                                label: _isSaving
                                    ? 'Saving…'
                                    : isUpdate
                                        ? 'Save Changes'
                                        : 'Save & Continue',
                                onTap: _onContinue,
                                scaleX: s.scale,
                                scaleY: s.scale,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isUpdate)
                        Center(
                          child: TextButton(
                            onPressed: _isSaving
                                ? null
                                : () => skipLawyerOnboardingToDashboard(context),
                            child: Text(
                              'Skip to dashboard',
                              style: AppTypography.inter(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                fontSize: s.fs(13),
                              ),
                            ),
                          ),
                        ),
                      if (!isUpdate)
                        Center(
                          child: TextButton(
                            onPressed: _isSaving ? null : _signOut,
                          child: Text(
                            'Sign out',
                            style: AppTypography.inter(
                              color: Colors.white54,
                              fontSize: s.fs(13),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: s.s(4)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
