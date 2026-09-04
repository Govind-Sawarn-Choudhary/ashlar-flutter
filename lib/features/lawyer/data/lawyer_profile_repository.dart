import 'dart:io';

import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/bar_enrollment_verification_result.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LawyerProfileRepository {
  LawyerProfileRepository._();

  static final LawyerProfileRepository instance = LawyerProfileRepository._();

  Future<LawyerAuthResponse> getMe() async {
    try {
      final json = await ApiClient.instance.getJson('/api/lawyer/me');
      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to load profile');
    }
  }

  Future<BarEnrollmentVerificationResult> verifyBarEnrollment({
    required String state,
    required String enrollmentNumber,
    String? fullName,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/lawyer/verify-bar-enrollment',
        body: {
          'state': state,
          'enrollmentNumber': enrollmentNumber,
          if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
        },
      );
      return BarEnrollmentVerificationResult.fromJson(json);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Bar Council verification failed');
    }
  }

  Future<LawyerAuthResponse> saveDetails({
    required String fullName,
    required String practiceAreas,
    required String experienceYears,
    required String bio,
  }) async {
    try {
      final json = await ApiClient.instance.putJson(
        '/api/lawyer/profile/details',
        body: {
          'fullName': fullName,
          'practiceAreas': practiceAreas,
          'experienceYears': experienceYears,
          'bio': bio,
        },
      );
      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to save details');
    }
  }

  Future<LawyerAuthResponse> uploadDocument({
    required String docType,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'docType': docType,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final json = await ApiClient.instance.postMultipart(
        '/api/lawyer/profile/documents',
        formData: formData,
      );

      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to upload document');
    }
  }

  Future<LawyerAuthResponse> completeDocuments({
    String? enrollmentNumber,
    String? state,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/lawyer/profile/documents/complete',
        body: {
          if (enrollmentNumber != null && enrollmentNumber.trim().isNotEmpty)
            'enrollmentNumber': enrollmentNumber.trim(),
          if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        },
      );
      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to complete documents');
    }
  }

  Future<LawyerAuthResponse> saveAvailability({
    required Set<int> selectedDays,
    required bool repeatWeekly,
    required String scheduleMode,
    DateTimeRange? weekRange,
    TimeOfDay? fromTime,
    TimeOfDay? toTime,
    Map<int, ({TimeOfDay from, TimeOfDay to})>? daySchedules,
  }) async {
    final sortedDays = selectedDays.toList()..sort();
    final isCustom = scheduleMode == 'custom';

    try {
      final json = await ApiClient.instance.putJson(
        '/api/lawyer/profile/availability',
        body: {
          'selectedDays': sortedDays,
          if (sortedDays.isNotEmpty) 'selectedDay': sortedDays.first,
          'repeatWeekly': repeatWeekly || sortedDays.length == 7,
          'scheduleMode': isCustom ? 'custom' : 'same',
          'weekStart': weekRange?.start.toIso8601String(),
          'weekEnd': weekRange?.end.toIso8601String(),
          if (!isCustom && fromTime != null && toTime != null) ...{
            'fromTime': _formatTime(fromTime),
            'toTime': _formatTime(toTime),
          },
          if (isCustom && daySchedules != null)
            'daySchedules': sortedDays
                .where(daySchedules.containsKey)
                .map((day) {
                  final schedule = daySchedules[day]!;
                  return {
                    'day': day,
                    'fromTime': _formatTime(schedule.from),
                    'toTime': _formatTime(schedule.to),
                  };
                })
                .toList(),
        },
      );
      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to save availability');
    }
  }

  Future<LawyerAuthResponse> saveFees(
    Map<String, LawyerConsultationFeeResult?> fees,
  ) async {
    try {
      final payload = LawyerConsultationFeeType.all.map((type) {
        final fee = fees[type.id];
        if (fee == null) {
          throw ApiException('Missing fee for ${type.title}');
        }

      return {
          'feeType': type.id,
          'amount': fee.amount.trim(),
          'durationLabel': fee.duration,
          'durationMinutes': _parseDurationMinutes(fee.duration),
          'location': fee.location,
        };
      }).toList();

      final json = await ApiClient.instance.putJson(
        '/api/lawyer/profile/fees',
        body: {'fees': payload},
      );

      return LawyerAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to save fees');
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  int _parseDurationMinutes(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
