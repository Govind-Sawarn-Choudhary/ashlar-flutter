import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';

class LawyerProfileHelpers {
  LawyerProfileHelpers._();

  static Map<String, LawyerConsultationFeeResult?> mapFees(
    List<LawyerFeeSnapshot> fees,
  ) {
    final mapped = {
      for (final type in LawyerConsultationFeeType.all) type.id: null as LawyerConsultationFeeResult?,
    };

    for (final fee in fees) {
      mapped[fee.feeType] = LawyerConsultationFeeResult(
        amount: fee.amount,
        duration: fee.durationLabel,
        location: fee.location,
      );
    }

    return mapped;
  }

  static TimeOfDay? parseTimeLabel(String? label) {
    if (label == null || label.trim().isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(label.trim());
    if (match == null) {
      return null;
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static Set<int> parseSelectedDays(LawyerAvailabilitySnapshot? availability) {
    if (availability == null || availability.selectedDays.isEmpty) {
      return {0};
    }
    return availability.selectedDays.toSet();
  }

  static String formatSelectedDaysLabel(Set<int> selectedDays) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (selectedDays.length == 7) {
      return 'Every day';
    }
    final sorted = selectedDays.toList()..sort();
    return sorted.map((day) => labels[day]).join(', ');
  }

  static DateTimeRange? parseWeekRange(LawyerAvailabilitySnapshot? availability) {
    if (availability?.weekStart == null || availability?.weekEnd == null) {
      return null;
    }

    final start = DateTime.tryParse(availability!.weekStart!);
    final end = DateTime.tryParse(availability.weekEnd!);
    if (start == null || end == null) {
      return null;
    }

    return DateTimeRange(start: start, end: end);
  }

  static Map<int, ({TimeOfDay from, TimeOfDay to})> parseDaySchedules(
    LawyerAvailabilitySnapshot? availability,
  ) {
    final map = <int, ({TimeOfDay from, TimeOfDay to})>{};
    if (availability == null) {
      return map;
    }

    for (final schedule in availability.daySchedules) {
      final from = parseTimeLabel(schedule.fromTime);
      final to = parseTimeLabel(schedule.toTime);
      if (from != null && to != null) {
        map[schedule.day] = (from: from, to: to);
      }
    }

    return map;
  }

  static String formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static int minutesFromMidnight(TimeOfDay time) => time.hour * 60 + time.minute;

  static bool isValidTimeRange(TimeOfDay? from, TimeOfDay? to) {
    if (from == null || to == null) {
      return false;
    }
    return minutesFromMidnight(to) > minutesFromMidnight(from);
  }

  static String verificationLabel(LawyerProfileSnapshot profile) {
    if (profile.isApproved) {
      return 'Approved by admin';
    }

    switch (profile.verificationStatus) {
      case 'approved':
        return 'Approved by admin';
      case 'rejected':
        return 'Rejected by admin';
      default:
        return profile.isProfileComplete
            ? 'Pending admin approval'
            : 'Complete onboarding';
    }
  }

  static String barVerificationLabel(LawyerProfileSnapshot profile) {
    if (profile.barEnrollmentVerified) {
      return 'Bar Council auto-verified';
    }
    if (profile.barManualReview) {
      return 'Bar Council — admin review required';
    }
    if (profile.barVerifiedName != null) {
      return 'Bar Council enrollment found';
    }
    return 'Bar Council not verified';
  }
}
