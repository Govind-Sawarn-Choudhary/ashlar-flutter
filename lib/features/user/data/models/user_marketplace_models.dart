class UserLawyerSummary {
  const UserLawyerSummary({
    required this.id,
    required this.fullName,
    this.practiceAreas,
    this.experienceYears,
    this.location,
    this.bio,
    this.isFavourite = false,
    this.fees = const [],
  });

  factory UserLawyerSummary.fromJson(Map<String, dynamic> json) {
    final feesJson = json['fees'];
    return UserLawyerSummary(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? 'Lawyer',
      practiceAreas: json['practiceAreas'] as String?,
      experienceYears: json['experienceYears'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      isFavourite: json['isFavourite'] as bool? ?? false,
      fees: feesJson is List
          ? feesJson
              .map((fee) => UserLawyerFee.fromJson(fee as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  final int id;
  final String fullName;
  final String? practiceAreas;
  final String? experienceYears;
  final String? location;
  final String? bio;
  final bool isFavourite;
  final List<UserLawyerFee> fees;

  double? feeAmountFor(String consultationType) {
    for (final fee in fees) {
      if (fee.feeType == consultationType) {
        return double.tryParse(fee.amount);
      }
    }
    return null;
  }
}

class UserLawyerFee {
  const UserLawyerFee({
    required this.feeType,
    required this.amount,
    this.durationLabel,
  });

  factory UserLawyerFee.fromJson(Map<String, dynamic> json) {
    return UserLawyerFee(
      feeType: json['fee_type'] as String? ?? json['feeType'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      durationLabel: json['duration_label'] as String? ??
          json['durationLabel'] as String?,
    );
  }

  final String feeType;
  final String amount;
  final String? durationLabel;
}

class UserWalletTransaction {
  const UserWalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  factory UserWalletTransaction.fromJson(Map<String, dynamic> json) {
    return UserWalletTransaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  final int id;
  final String type;
  final double amount;
  final String? description;
  final String? createdAt;
}

class UserDocumentCategory {
  const UserDocumentCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  factory UserDocumentCategory.fromJson(Map<String, dynamic> json) {
    return UserDocumentCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final String slug;
  final String? description;
}

class UserDocumentProduct {
  const UserDocumentProduct({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  factory UserDocumentProduct.fromJson(Map<String, dynamic> json) {
    return UserDocumentProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final double price;
  final String? description;
}

class UserChallanItem {
  const UserChallanItem({
    required this.id,
    required this.vehicleNumber,
    required this.title,
    required this.amount,
    required this.status,
  });

  factory UserChallanItem.fromJson(Map<String, dynamic> json) {
    return UserChallanItem(
      id: json['id'] as int,
      vehicleNumber: json['vehicleNumber'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  final int id;
  final String vehicleNumber;
  final String title;
  final double amount;
  final String status;
}

class UserBookingResult {
  const UserBookingResult({
    required this.appointmentId,
    required this.amount,
    required this.reference,
    required this.paymentTime,
    required this.durationMinutes,
    this.consultationType,
    this.mode,
  });

  factory UserBookingResult.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>? ?? {};
    final appointment = json['appointment'] as Map<String, dynamic>? ?? {};
    return UserBookingResult(
      appointmentId: appointment['id'] as int? ?? 0,
      amount: (payment['amount'] as num?)?.toDouble() ?? 0,
      reference: payment['reference'] as String? ?? '',
      paymentTime: DateTime.tryParse(payment['createdAt'] as String? ?? '') ??
          DateTime.now(),
      durationMinutes: appointment['durationMinutes'] as int? ?? 30,
      consultationType: appointment['consultationType'] as String?,
      mode: appointment['mode'] as String?,
    );
  }

  final int appointmentId;
  final double amount;
  final String reference;
  final DateTime paymentTime;
  final int durationMinutes;
  final String? consultationType;
  final String? mode;
}

class UserSupportInfo {
  const UserSupportInfo({
    required this.supportPhone,
    required this.socialLinks,
  });

  factory UserSupportInfo.fromJson(Map<String, dynamic> json) {
    final links = json['socialLinks'] as Map<String, dynamic>? ?? {};
    return UserSupportInfo(
      supportPhone: json['supportPhone'] as String? ?? '',
      socialLinks: links.map((key, value) => MapEntry(key, value as String)),
    );
  }

  final String supportPhone;
  final Map<String, String> socialLinks;
}
