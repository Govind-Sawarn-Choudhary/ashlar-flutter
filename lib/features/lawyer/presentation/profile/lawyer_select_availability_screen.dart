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
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_calendar_picker.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_panel.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_time_picker.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';

/// Lawyer onboarding step 3 — set consultation availability.
class LawyerSelectAvailabilityScreen extends StatefulWidget {
  const LawyerSelectAvailabilityScreen({super.key});

  @override
  State<LawyerSelectAvailabilityScreen> createState() =>
      _LawyerSelectAvailabilityScreenState();
}

class _LawyerSelectAvailabilityScreenState
    extends State<LawyerSelectAvailabilityScreen> {
  static const _allDays = {0, 1, 2, 3, 4, 5, 6};

  Set<int> _selectedDays = {0};
  bool _repeatWeekly = false;
  DateTimeRange? _selectedWeekRange;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  bool _isSaving = false;
  bool _loading = true;

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
        _repeatWeekly = availability.repeatWeekly || _selectedDays.length == 7;
        _selectedWeekRange = LawyerProfileHelpers.parseWeekRange(availability);
        _fromTime = LawyerProfileHelpers.parseTimeLabel(availability.fromTime);
        _toTime = LawyerProfileHelpers.parseTimeLabel(availability.toTime);
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

  Future<void> _pickTime({required bool isFrom}) async {
    final picked = await LawyerAvailabilityTimePicker.show(
      context,
      initialTime: (isFrom ? _fromTime : _toTime) ?? TimeOfDay.now(),
      title: isFrom ? 'Start time' : 'End time',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isFrom) {
        _fromTime = picked;
      } else {
        _toTime = picked;
      }
    });
  }

  void _toggleDay(int index) {
    setState(() {
      final next = Set<int>.from(_selectedDays);
      if (next.contains(index)) {
        next.remove(index);
      } else {
        next.add(index);
      }
      _selectedDays = next;
      _repeatWeekly = next.length == _allDays.length;
    });
  }

  void _setRepeatWeekly(bool value) {
    setState(() {
      _repeatWeekly = value;
      if (value) {
        _selectedDays = Set<int>.from(_allDays);
      }
    });
  }

  int _minutesFromMidnight(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _onContinue() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one working day.')),
      );
      return;
    }

    if (_fromTime == null || _toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your start and end time.'),
        ),
      );
      return;
    }

    if (_minutesFromMidnight(_toTime!) <= _minutesFromMidnight(_fromTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
        ),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await LawyerProfileRepository.instance.saveAvailability(
        selectedDays: _selectedDays,
        repeatWeekly: _repeatWeekly,
        weekRange: _selectedWeekRange,
        fromTime: _fromTime!,
        toTime: _toTime!,
      );

      if (!mounted) {
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FigmaScreenCanvas(
              builder: (context, s) {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: s.s(8)),
                      LawyerSetupStepBar(
                        scale: s,
                        activeStep: 2,
                        showProgressTracks: true,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set Your Availability',
                              style: AppTypography.inter(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: s.fs(20),
                              ),
                            ),
                            SizedBox(height: s.s(6)),
                            Text(
                              'Step 3 of 3 — Pick your days and hours. You can select multiple days like Mon, Wed & Fri.',
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
                          padding: EdgeInsets.fromLTRB(s.s(16), s.s(16), s.s(16), s.s(8)),
                          child: LawyerAvailabilityPanel(
                            selectedDays: _selectedDays,
                            repeatWeekly: _repeatWeekly,
                            selectedWeek: _selectedWeekRange != null
                                ? formatAvailabilityDateRange(_selectedWeekRange!)
                                : null,
                            fromTime: _fromTime,
                            toTime: _toTime,
                            onWeekTap: _pickWeek,
                            onDayToggled: _toggleDay,
                            onFromTap: () => _pickTime(isFrom: true),
                            onToTap: () => _pickTime(isFrom: false),
                            onRepeatChanged: _setRepeatWeekly,
                            onClearDateRange: () =>
                                setState(() => _selectedWeekRange = null),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(s.s(18), s.s(8), s.s(18), s.s(16)),
                        child: ProfileContinueButton(
                          label: _isSaving ? 'Saving…' : 'Save & Continue',
                          onTap: _onContinue,
                          scaleX: s.scale,
                          scaleY: s.scale,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
