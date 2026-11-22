/// Official traffic challan portals (MoRTH / Parivahan).
abstract final class ChallanPortalConfig {
  /// Primary accused-challan check (government eChallan).
  static const String accusedChallanUrl =
      'https://echallan.parivahan.gov.in/index/accused-challan';

  static const String portalName = 'eChallan (Parivahan)';
  static const String portalAuthority =
      'Ministry of Road Transport & Highways, Government of India';
}