/// In-memory user profile fields — shared with manage profile screen.
class UserProfileStore {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  String fullName = 'Rishabh';
  String location = 'New Delhi';
  String email = "Loremipsum@gmail.com";
  String language = 'Hindi';

  void save({
    required String fullName,
    required String location,
    required String email,
    required String language,
  }) {
    this.fullName = fullName;
    this.location = location;
    this.email = email;
    this.language = language;
  }
}
