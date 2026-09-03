class BarEnrollmentVerificationResult {
  const BarEnrollmentVerificationResult({
    required this.verified,
    required this.state,
    required this.inputEnrollmentNumber,
    this.enrollmentFound = false,
    this.needsManualReview = false,
    this.nameMatched,
    this.matchedEnrollmentNumber,
    this.advocateName,
    this.fatherName,
    this.district,
    this.enrollmentDate,
    this.address,
    this.copNumber,
    this.message,
  });

  final bool verified;
  final bool enrollmentFound;
  final bool needsManualReview;
  final bool? nameMatched;
  final String state;
  final String inputEnrollmentNumber;
  final String? matchedEnrollmentNumber;
  final String? advocateName;
  final String? fatherName;
  final String? district;
  final String? enrollmentDate;
  final String? address;
  final String? copNumber;
  final String? message;

  bool get canContinue => verified || needsManualReview || enrollmentFound;

  factory BarEnrollmentVerificationResult.fromJson(Map<String, dynamic> json) {
    return BarEnrollmentVerificationResult(
      verified: json['verified'] as bool? ?? false,
      enrollmentFound: json['enrollmentFound'] as bool? ?? false,
      needsManualReview: json['needsManualReview'] as bool? ?? false,
      nameMatched: json['nameMatched'] as bool?,
      state: json['state'] as String? ?? 'UP',
      inputEnrollmentNumber: json['inputEnrollmentNumber'] as String? ?? '',
      matchedEnrollmentNumber: json['matchedEnrollmentNumber'] as String?,
      advocateName: json['advocateName'] as String?,
      fatherName: json['fatherName'] as String?,
      district: json['district'] as String?,
      enrollmentDate: json['enrollmentDate'] as String?,
      address: json['address'] as String?,
      copNumber: json['copNumber'] as String?,
      message: json['message'] as String?,
    );
  }
}
