class UserAuthResponse {
  const UserAuthResponse({
    required this.token,
    required this.isNewUser,
    required this.nextRoute,
    required this.profile,
    this.phone,
  });

  final String token;
  final bool isNewUser;
  final String nextRoute;
  final UserProfileSnapshot profile;
  final String? phone;

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return UserAuthResponse(
      token: json['token'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      nextRoute: json['nextRoute'] as String? ?? 'create_account',
      phone: user['phone'] as String?,
      profile: UserProfileSnapshot.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class UserProfileSnapshot {
  const UserProfileSnapshot({
    this.fullName,
    this.location,
    this.email,
    this.language,
    this.isProfileComplete = false,
  });

  final String? fullName;
  final String? location;
  final String? email;
  final String? language;
  final bool isProfileComplete;

  factory UserProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return UserProfileSnapshot(
      fullName: json['fullName'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      language: json['language'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }
}
