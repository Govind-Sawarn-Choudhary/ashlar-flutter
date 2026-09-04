import 'dart:convert';

class LawyerAuthResponse {
  const LawyerAuthResponse({
    required this.token,
    required this.isNewUser,
    required this.nextRoute,
    required this.lawyer,
    this.userPhone,
    this.documents = const [],
    this.fees = const [],
    this.availability,
  });

  final String token;
  final bool isNewUser;
  final String nextRoute;
  final LawyerProfileSnapshot lawyer;
  final String? userPhone;
  final List<LawyerDocumentSnapshot> documents;
  final List<LawyerFeeSnapshot> fees;
  final LawyerAvailabilitySnapshot? availability;

  factory LawyerAuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return LawyerAuthResponse(
      token: json['token'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      nextRoute: json['nextRoute'] as String? ?? 'verify_details',
      userPhone: user?['phone'] as String?,
      lawyer: LawyerProfileSnapshot.fromJson(
        json['lawyer'] as Map<String, dynamic>? ?? {},
      ),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => LawyerDocumentSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
      fees: (json['fees'] as List<dynamic>? ?? [])
          .map((e) => LawyerFeeSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
      availability: json['availability'] == null
          ? null
          : LawyerAvailabilitySnapshot.fromJson(
              json['availability'] as Map<String, dynamic>,
            ),
    );
  }
}

class LawyerProfileSnapshot {
  const LawyerProfileSnapshot({
    this.fullName,
    this.practiceAreas,
    this.experienceYears,
    this.bio,
    this.location,
    this.barState,
    this.barEnrollmentNumber,
    this.barEnrollmentVerified = false,
    this.barVerifiedName,
    this.barCopNumber,
    this.barVerifiedAddress,
    this.barVerifiedEnrollmentDate,
    this.barManualReview = false,
    this.barNameMatched,
    this.onboardingStep = 'details',
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.isProfileComplete = false,
    this.isApproved = false,
  });

  final String? fullName;
  final String? practiceAreas;
  final String? experienceYears;
  final String? bio;
  final String? location;
  final String? barState;
  final String? barEnrollmentNumber;
  final bool barEnrollmentVerified;
  final String? barVerifiedName;
  final String? barCopNumber;
  final String? barVerifiedAddress;
  final String? barVerifiedEnrollmentDate;
  final bool barManualReview;
  final bool? barNameMatched;
  final String onboardingStep;
  final String verificationStatus;
  final String? rejectionReason;
  final bool isProfileComplete;
  final bool isApproved;

  factory LawyerProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return LawyerProfileSnapshot(
      fullName: json['fullName'] as String?,
      practiceAreas: json['practiceAreas'] as String?,
      experienceYears: json['experienceYears'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      barState: json['barState'] as String?,
      barEnrollmentNumber: json['barEnrollmentNumber'] as String?,
      barEnrollmentVerified: json['barEnrollmentVerified'] as bool? ?? false,
      barVerifiedName: json['barVerifiedName'] as String?,
      barCopNumber: json['barCopNumber'] as String?,
      barVerifiedAddress: json['barVerifiedAddress'] as String?,
      barVerifiedEnrollmentDate: json['barVerifiedEnrollmentDate'] as String?,
      barManualReview: json['barManualReview'] as bool? ?? false,
      barNameMatched: json['barNameMatched'] as bool?,
      onboardingStep: json['onboardingStep'] as String? ?? 'details',
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }
}

class LawyerDocumentSnapshot {
  const LawyerDocumentSnapshot({
    required this.docType,
    required this.fileName,
    required this.filePath,
  });

  final String docType;
  final String fileName;
  final String filePath;

  factory LawyerDocumentSnapshot.fromJson(Map<String, dynamic> json) {
    return LawyerDocumentSnapshot(
      docType: json['doc_type'] as String? ?? json['docType'] as String? ?? '',
      fileName: json['file_name'] as String? ?? json['fileName'] as String? ?? '',
      filePath: json['file_path'] as String? ?? json['filePath'] as String? ?? '',
    );
  }
}

class LawyerFeeSnapshot {
  const LawyerFeeSnapshot({
    required this.feeType,
    required this.amount,
    required this.durationLabel,
    this.location,
  });

  final String feeType;
  final String amount;
  final String durationLabel;
  final String? location;

  factory LawyerFeeSnapshot.fromJson(Map<String, dynamic> json) {
    return LawyerFeeSnapshot(
      feeType: json['fee_type'] as String? ?? json['feeType'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      durationLabel:
          json['duration_label'] as String? ?? json['durationLabel'] as String? ?? '',
      location: json['location'] as String?,
    );
  }
}

class LawyerAvailabilitySnapshot {
  const LawyerAvailabilitySnapshot({
    this.selectedDay = 0,
    this.selectedDays = const [0],
    this.repeatWeekly = false,
    this.weekStart,
    this.weekEnd,
    this.fromTime,
    this.toTime,
  });

  final int selectedDay;
  final List<int> selectedDays;
  final bool repeatWeekly;
  final String? weekStart;
  final String? weekEnd;
  final String? fromTime;
  final String? toTime;

  factory LawyerAvailabilitySnapshot.fromJson(Map<String, dynamic> json) {
    final parsedDays = _parseSelectedDays(json);
    return LawyerAvailabilitySnapshot(
      selectedDay: json['selected_day'] as int? ?? json['selectedDay'] as int? ?? parsedDays.first,
      selectedDays: parsedDays,
      repeatWeekly: (json['repeat_weekly'] as int? ?? json['repeatWeekly'] as int? ?? 0) == 1
          || (json['repeatWeekly'] as bool? ?? false),
      weekStart: json['week_start'] as String? ?? json['weekStart'] as String?,
      weekEnd: json['week_end'] as String? ?? json['weekEnd'] as String?,
      fromTime: json['from_time'] as String? ?? json['fromTime'] as String?,
      toTime: json['to_time'] as String? ?? json['toTime'] as String?,
    );
  }

  static List<int> _parseSelectedDays(Map<String, dynamic> json) {
    final raw = json['selectedDays'] ?? json['selected_days'];
    if (raw is List) {
      final days = raw
          .map((day) => day is int ? day : int.tryParse('$day') ?? -1)
          .where((day) => day >= 0 && day <= 6)
          .toSet()
          .toList()
        ..sort();
      if (days.isNotEmpty) {
        return days;
      }
    }

    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is List) {
          final days = parsed
              .map((day) => day is int ? day : int.tryParse('$day') ?? -1)
              .where((day) => day >= 0 && day <= 6)
              .toSet()
              .toList()
            ..sort();
          if (days.isNotEmpty) {
            return days;
          }
        }
      } catch (_) {
        // Fall through to legacy single-day field.
      }
    }

    final repeatWeekly = (json['repeat_weekly'] as int? ?? json['repeatWeekly'] as int? ?? 0) == 1
        || (json['repeatWeekly'] as bool? ?? false);
    if (repeatWeekly) {
      return [0, 1, 2, 3, 4, 5, 6];
    }

    final singleDay = json['selected_day'] as int? ?? json['selectedDay'] as int? ?? 0;
    return [singleDay.clamp(0, 6)];
  }
}
