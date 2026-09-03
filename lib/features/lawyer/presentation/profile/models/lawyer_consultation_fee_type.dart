import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';

/// Consultation fee row — Figma `7125:5885` list items.
class LawyerConsultationFeeType {
  const LawyerConsultationFeeType({
    required this.id,
    required this.iconAsset,
    required this.iconSize,
    required this.title,
    required this.subtitle,
    required this.consultationFeeHeading,
    this.feeHeroAsset,
    this.heroX = 97,
    this.heroY = 145,
    this.heroSize = 189,
    this.amountFieldY = 495,
    this.durationFieldY = 567,
    this.saveY = 660,
    this.hasLocationField = false,
    this.rowHeight = 34,
  });

  final String id;
  final String iconAsset;
  final double iconSize;
  final String title;
  final String subtitle;
  final String consultationFeeHeading;
  final String? feeHeroAsset;
  final double heroX;
  final double heroY;
  final double heroSize;
  final double amountFieldY;
  final double durationFieldY;
  final double saveY;
  final bool hasLocationField;
  final double rowHeight;

  static const chat = LawyerConsultationFeeType(
    id: 'chat',
    iconAsset: AppAssets.feeChatIcon,
    iconSize: 22.55,
    title: 'Chat',
    subtitle: 'Text chat consultation',
    consultationFeeHeading: 'Chat Consultation Fee',
    feeHeroAsset: AppAssets.chatFeeHero,
    rowHeight: 34,
  );

  static const audio = LawyerConsultationFeeType(
    id: 'audio',
    iconAsset: AppAssets.feeAudioIcon,
    iconSize: 24,
    title: 'Audio Call',
    subtitle: 'Audio call consultation',
    consultationFeeHeading: 'Audio Call Consultation Fee',
    feeHeroAsset: AppAssets.audioFeeHero,
    rowHeight: 32,
  );

  static const video = LawyerConsultationFeeType(
    id: 'video',
    iconAsset: AppAssets.feeVideoIcon,
    iconSize: 25.65,
    title: 'Video Call',
    subtitle: 'Video call consultation',
    consultationFeeHeading: 'Video Call Consultation Fee',
    feeHeroAsset: AppAssets.videoFeeHero,
    rowHeight: 33,
  );

  static const physical = LawyerConsultationFeeType(
    id: 'physical',
    iconAsset: AppAssets.feePhysicalIcon,
    iconSize: 24.12,
    title: 'Physical  Meet',
    subtitle: 'In Person consultation',
    consultationFeeHeading: 'In Person Consultation',
    feeHeroAsset: AppAssets.inPersonFeeHero,
    heroX: 84,
    heroY: 155,
    heroSize: 210,
    amountFieldY: 495,
    durationFieldY: 567,
    saveY: 700,
    hasLocationField: true,
    rowHeight: 31,
  );

  static const all = [chat, audio, video, physical];

  static LawyerConsultationFeeType? fromId(String id) {
    for (final type in all) {
      if (type.id == id) {
        return type;
      }
    }
    return null;
  }
}

/// Formats duration labels per Figma `7125:5537` — e.g. "1 Minute", "2 Minutes".
String formatConsultationDurationLabel(int minutes) {
  if (minutes == 1) {
    return '1 Minute';
  }
  return '$minutes Minutes';
}

/// All duration options from 1 to 60 minutes.
List<String> get consultationDurationOptions =>
    List.generate(60, (i) => formatConsultationDurationLabel(i + 1));
