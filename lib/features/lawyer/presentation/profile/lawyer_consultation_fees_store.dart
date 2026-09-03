import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';

/// In-memory consultation fees — shared between registration and profile update.
class LawyerConsultationFeesStore {
  LawyerConsultationFeesStore._();

  static final LawyerConsultationFeesStore instance =
      LawyerConsultationFeesStore._();

  Map<String, LawyerConsultationFeeResult?> _fees = {
    for (final type in LawyerConsultationFeeType.all) type.id: null,
  };

  Map<String, LawyerConsultationFeeResult?> copyFees() =>
      Map<String, LawyerConsultationFeeResult?>.from(_fees);

  void saveAll(Map<String, LawyerConsultationFeeResult?> fees) {
    _fees = Map<String, LawyerConsultationFeeResult?>.from(fees);
  }
}
