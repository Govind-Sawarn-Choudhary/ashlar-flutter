import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium consultation fee editor for chat, audio, video, and in-person meet.
class LawyerAddConsultationFeeScreen extends StatefulWidget {
  const LawyerAddConsultationFeeScreen({
    super.key,
    required this.consultationType,
    this.initialAmount,
    this.initialDuration,
    this.initialLocation,
  });

  final LawyerConsultationFeeType consultationType;
  final String? initialAmount;
  final String? initialDuration;
  final String? initialLocation;

  @override
  State<LawyerAddConsultationFeeScreen> createState() =>
      _LawyerAddConsultationFeeScreenState();
}

class _LawyerAddConsultationFeeScreenState
    extends State<LawyerAddConsultationFeeScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _locationController;
  String? _selectedDuration;

  LawyerConsultationFeeType get type => widget.consultationType;

  Color get _accent => switch (type.id) {
        'chat' => const Color(0xFF1976D2),
        'audio' => const Color(0xFF7B1FA2),
        'video' => const Color(0xFFD84315),
        'physical' => const Color(0xFF388E3C),
        _ => AppColors.gold,
      };

  bool get _isEditing =>
      (widget.initialAmount?.trim().isNotEmpty ?? false) ||
      (widget.initialDuration?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _locationController =
        TextEditingController(text: widget.initialLocation ?? '');
    _selectedDuration = widget.initialDuration;
    _amountController.addListener(_onFieldsChanged);
    _locationController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  @override
  void dispose() {
    _amountController
      ..removeListener(_onFieldsChanged)
      ..dispose();
    _locationController
      ..removeListener(_onFieldsChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _pickDuration() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select duration',
                        style: AppTypography.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: consultationDurationOptions.length,
                  itemBuilder: (context, index) {
                    final option = consultationDurationOptions[index];
                    final isSelected = option == _selectedDuration;
                    return ListTile(
                      title: Text(
                        option,
                        style: AppTypography.inter(
                          color: isSelected ? AppColors.gold : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: AppColors.gold)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selectedDuration = picked);
  }

  void _onSave() {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_selectedDuration == null || _selectedDuration!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a duration')),
      );
      return;
    }
    final location = _locationController.text.trim();
    if (type.hasLocationField && location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a meeting location')),
      );
      return;
    }
    Navigator.of(context).pop(
      LawyerConsultationFeeResult(
        amount: amount,
        duration: _selectedDuration!,
        location: type.hasLocationField ? location : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(s.s(8), s.s(4), s.s(8), 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(left: s.s(7)),
                          child: Image.asset(
                            AppAssets.walletBackButton,
                            width: s.s(40),
                            height: s.s(40),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          type.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: s.fs(16),
                          ),
                        ),
                      ),
                      SizedBox(width: s.s(47)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      s.s(16),
                      s.s(16),
                      s.s(16),
                      s.s(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroCard(
                          type: type,
                          accent: _accent,
                          isEditing: _isEditing,
                        ),
                        SizedBox(height: s.s(16)),
                        _FormCard(
                          accent: _accent,
                          amountController: _amountController,
                          selectedDuration: _selectedDuration,
                          onDurationTap: _pickDuration,
                          locationController: type.hasLocationField
                              ? _locationController
                              : null,
                        ),
                        SizedBox(height: s.s(14)),
                        _TipsCard(type: type, accent: _accent),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    s.s(18),
                    s.s(8),
                    s.s(18),
                    s.s(12) + (keyboardInset > 0 ? keyboardInset : 0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: s.s(52),
                    child: GoldActionButton(
                      label: _isEditing ? 'Update Fee' : 'Save Fee',
                      onTap: _onSave,
                      scaleX: s.scale,
                      scaleY: s.scale,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.type,
    required this.accent,
    required this.isEditing,
  });

  final LawyerConsultationFeeType type;
  final Color accent;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final hero = type.feeHeroAsset ?? type.iconAsset;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.04),
            const Color(0xFF1A1A2E).withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                hero,
                fit: type.id == 'chat' || type.id == 'physical'
                    ? BoxFit.cover
                    : BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isEditing ? 'Update rate' : 'Set rate',
                    style: AppTypography.inter(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type.consultationFeeHeading,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.subtitle,
                  style: AppTypography.inter(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.accent,
    required this.amountController,
    required this.selectedDuration,
    required this.onDurationTap,
    this.locationController,
  });

  final Color accent;
  final TextEditingController amountController;
  final String? selectedDuration;
  final VoidCallback onDurationTap;
  final TextEditingController? locationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fee details',
            style: AppTypography.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clients will see this price when booking ${locationController != null ? 'an in-person session' : 'this consultation'}.',
            style: AppTypography.inter(
              color: Colors.white54,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(label: 'Consultation fee (₹)', accent: accent),
          const SizedBox(height: 8),
          _AmountField(controller: amountController),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Session duration', accent: accent),
          const SizedBox(height: 8),
          _DurationField(
            value: selectedDuration,
            onTap: onDurationTap,
          ),
          if (locationController != null) ...[
            const SizedBox(height: 14),
            _FieldLabel(label: 'Meeting location', accent: accent),
            const SizedBox(height: 8),
            _LocationField(controller: locationController!),
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.inter(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '₹',
            style: AppTypography.inter(
              color: hasValue ? Colors.black : const Color(0xFF808080),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.inter(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: AppTypography.inter(
                  color: const Color(0xFF808080),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.value,
    required this.onTap,
  });

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? value! : 'Select duration',
                  style: AppTypography.inter(
                    color: hasValue ? Colors.black : const Color(0xFF808080),
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: AppTypography.inter(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Office address or meeting point',
          hintStyle: AppTypography.inter(
            color: const Color(0xFF808080),
            fontSize: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.type, required this.accent});

  final LawyerConsultationFeeType type;
  final Color accent;

  String get _tip => switch (type.id) {
        'chat' => 'Keep chat fees lower for quick legal queries and follow-ups.',
        'audio' =>
            'Audio calls work well for detailed advice without video setup.',
        'video' =>
            'Video consultations are ideal for document review and face-to-face trust.',
        'physical' =>
            'Add a clear office address so clients know where to meet you.',
        _ => 'Set a competitive rate for your experience and practice area.',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _tip,
              style: AppTypography.inter(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saved fee payload returned to the fee list screen.
class LawyerConsultationFeeResult {
  const LawyerConsultationFeeResult({
    required this.amount,
    required this.duration,
    this.location,
  });

  final String amount;
  final String duration;
  final String? location;
}

/// Route args for [`LawyerAddConsultationFeeScreen`].
class LawyerAddConsultationFeeArgs {
  const LawyerAddConsultationFeeArgs({
    required this.consultationType,
    this.initialAmount,
    this.initialDuration,
    this.initialLocation,
  });

  final LawyerConsultationFeeType consultationType;
  final String? initialAmount;
  final String? initialDuration;
  final String? initialLocation;
}
