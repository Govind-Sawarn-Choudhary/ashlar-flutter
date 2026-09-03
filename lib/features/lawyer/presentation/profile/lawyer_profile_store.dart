/// In-memory lawyer profile fields — shared with manage profile screen.
class LawyerProfileStore {
  LawyerProfileStore._();

  static final LawyerProfileStore instance = LawyerProfileStore._();

  String fullName = 'Komal Rana';
  String practiceArea = 'Divoirce Lawyer';
  String experience = '3 Years Of experience';
  String bio = 'My Bio Lorem Ipsum';

  void save({
    required String fullName,
    required String practiceArea,
    required String experience,
    required String bio,
  }) {
    this.fullName = fullName;
    this.practiceArea = practiceArea;
    this.experience = experience;
    this.bio = bio;
  }
}
