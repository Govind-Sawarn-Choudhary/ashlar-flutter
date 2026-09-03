import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_time_picker.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_calendar_picker.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_availability_panel.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';

/// Lawyer profile step 3 — Figma frames
/// [`7125:5766`](https://www.figma.com/design/lOlDO1Q7rirgmwIPUf9VMP/ashlarlawyerhub-To-Share?node-id=7125-5766) (main),
/// [`7125:5816`](https://www.figma.com/design/lOlDO1Q7rirgmwIPUf9VMP/ashlarlawyerhub-To-Share?node-id=7125-5816) (calendar week),
/// [`7125:6027`](https://www.figma.com/design/lOlDO1Q7rirgmwIPUf9VMP/ashlarlawyerhub-To-Share?node-id=7125-6027) (time picker).
/// Continue → [`7125:5866`](https://www.figma.com/design/lOlDO1Q7rirgmwIPUf9VMP/ashlarlawyerhub-To-Share?node-id=7125-5866) (Fee and Charges).
class LawyerSelectAvailabilityScreen extends StatefulWidget {
  const LawyerSelectAvailabilityScreen({super.key});

  @override
  State<LawyerSelectAvailabilityScreen> createState() =>
      _LawyerSelectAvailabilityScreenState();
}

class _LawyerSelectAvailabilityScreenState
    extends State<LawyerSelectAvailabilityScreen> {
  int _selectedDay = 0;
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
        _selectedDay = availability.selectedDay;
        _repeatWeekly = availability.repeatWeekly;
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

  Future<void> _onContinue() async {
    if (_fromTime == null || _toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select from and to time')),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await LawyerProfileRepository.instance.saveAvailability(
        selectedDay: _selectedDay,
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
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: s.s(113),
                child: LawyerSectionHeading(
                  title: 'Verify Your Details',
                  scale: s,
                  titleWidth: 143,
                ),
              ),
              Positioned(
                left: 0,
                top: s.s(164),
                child: LawyerSetupStepBar(
                  scale: s,
                  activeStep: 2,
                  showProgressTracks: true,
                ),
              ),
              Positioned(
                left: s.s(15),
                top: s.s(246),
                width: s.s(329),
                height: s.s(352),
                child: LawyerAvailabilityPanel(
                  scale: s,
                  selectedDay: _selectedDay,
                  repeatWeekly: _repeatWeekly,
                  selectedWeek: _selectedWeekRange != null
                      ? formatAvailabilityDateRange(_selectedWeekRange!)
                      : null,
                  fromTime: _fromTime,
                  toTime: _toTime,
                  onWeekTap: _pickWeek,
                  onDaySelected: (index) => setState(() => _selectedDay = index),
                  onFromTap: () => _pickTime(isFrom: true),
                  onToTap: () => _pickTime(isFrom: false),
                  onRepeatChanged: (value) =>
                      setState(() => _repeatWeekly = value),
                ),
              ),
              Positioned(
                left: s.s(18),
                top: s.s(632),
                width: s.s(324),
                height: s.s(52),
                child: ProfileContinueButton(
                  label: _isSaving ? 'Saving…' : 'Continue',
                  onTap: _onContinue,
                  scaleX: s.scale,
                  scaleY: s.scale,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
