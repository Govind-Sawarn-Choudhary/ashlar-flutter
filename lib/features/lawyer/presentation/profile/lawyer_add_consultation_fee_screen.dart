import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Consultation fee form — Figma [`7125:5507`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-5507) Profile 8 (chat/audio/video) and [`7125:5567`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-5567) Profile 11 (in person).
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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _locationController =
        TextEditingController(text: widget.initialLocation ?? '');
    _selectedDuration = widget.initialDuration;
    _amountController.addListener(_onAmountChanged);
    _locationController.addListener(_onLocationChanged);
  }

  void _onAmountChanged() => setState(() {});

  void _onLocationChanged() => setState(() {});

  @override
  void dispose() {
    _amountController
      ..removeListener(_onAmountChanged)
      ..dispose();
    _locationController
      ..removeListener(_onLocationChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _pickDuration() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Select Duration',
                  style: AppTypography.inter(
                    color: const Color(0xFF070707),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1,
                  ),
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
                          color: isSelected
                              ? AppColors.gold
                              : const Color(0xFF070707),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
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
    if (widget.consultationType.hasLocationField && location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a meeting location')),
      );
      return;
    }
    Navigator.of(context).pop(
      LawyerConsultationFeeResult(
        amount: amount,
        duration: _selectedDuration!,
        location: widget.consultationType.hasLocationField ? location : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.consultationType;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: s.s(type.heroX),
                top: s.s(type.heroY),
                width: s.s(type.heroSize),
                height: s.s(type.heroSize),
                child: _HeroImage(type: type, scale: s),
              ),
              Positioned(
                left: s.s(_Tokens.headingX),
                top: s.s(_Tokens.headingY),
                width: s.s(_Tokens.headingW),
                height: s.s(_Tokens.headingH),
                child: Center(
                  child: Text(
                    type.consultationFeeHeading,
                    textAlign: TextAlign.center,
                    style: AppTypography.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: s.fs(24),
                      height: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: s.s(_Tokens.fieldX),
                top: s.s(type.amountFieldY),
                width: s.s(_Tokens.fieldW),
                height: s.s(_Tokens.fieldH),
                child: _AmountField(
                  scale: s,
                  controller: _amountController,
                ),
              ),
              Positioned(
                left: s.s(_Tokens.fieldX),
                top: s.s(type.durationFieldY),
                width: s.s(_Tokens.fieldW),
                height: s.s(_Tokens.fieldH),
                child: _DurationField(
                  scale: s,
                  value: _selectedDuration,
                  onTap: _pickDuration,
                ),
              ),
              if (type.hasLocationField)
                Positioned(
                  left: s.s(_Tokens.fieldX),
                  top: s.s(_Tokens.locationFieldY),
                  width: s.s(_Tokens.fieldW),
                  height: s.s(_Tokens.fieldH),
                  child: _LocationField(
                    scale: s,
                    controller: _locationController,
                  ),
                ),
              Positioned(
                left: s.s(_Tokens.saveX),
                top: s.s(type.saveY),
                width: s.s(_Tokens.saveW),
                height: s.s(_Tokens.saveH),
                child: ProfileContinueButton(
                  label: 'Save Fee',
                  onTap: _onSave,
                  scaleX: s.scale,
                  scaleY: s.scale,
                ),
              ),
              Positioned(
                left: 0,
                top: s.s(_Tokens.headerTitleY),
                width: s.viewportWidth,
                child: IgnorePointer(
                  child: Transform.translate(
                    offset: Offset(s.s(_Tokens.headerTitleOffsetX), 0),
                    child: Text(
                      type.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: s.fs(16),
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: s.s(_Tokens.backX),
                top: s.s(_Tokens.backY),
                width: s.s(_Tokens.backSize),
                height: s.s(_Tokens.backSize),
                child: _BackButton(
                  scale: s,
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Saved fee payload from [`7125:5507`] / [`7125:5567`].
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

abstract final class _Tokens {
  static const backX = 23.0;
  static const backY = 67.0;
  static const backSize = 40.0;
  static const headerTitleY = 78.0;
  static const headerTitleOffsetX = 16.0;
  static const headingX = 18.0;
  static const headingY = 423.0;
  static const headingW = 324.0;
  static const headingH = 45.0;
  static const fieldX = 18.0;
  static const fieldW = 320.0;
  static const fieldH = 52.0;
  static const locationFieldY = 633.0;
  static const saveX = 18.0;
  static const saveW = 324.0;
  static const saveH = 52.0;

  static const fieldRadius = 10.0;
  /// Figma label @ x=35, field @ x=18.
  static const fieldPadH = 17.0;
  /// Figma chevron `7125:5514` @ x=307, field ends x=338 → 13px inset.
  static const chevronPadR = 13.0;
  static const chevronSize = 18.0;
  static const placeholderColor = Color(0xFF808080);
  static const filledTextColor = Color(0xFF000000);
  static const backFill = Color(0xFFFAFAFA);
  static const backBorder = Color(0xFFDBDBDB);

  static const fieldShadow = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 4,
    offset: Offset.zero,
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.scale, required this.onTap});

  final FigmaScale scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = scale.s(_Tokens.backSize);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _Tokens.backFill,
          border: Border.all(color: _Tokens.backBorder),
          borderRadius: BorderRadius.circular(scale.s(36.8)),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new,
          color: const Color(0xFF151A2E),
          size: scale.s(18),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.type, required this.scale});

  final LawyerConsultationFeeType type;
  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    final hero = type.feeHeroAsset ?? type.iconAsset;
    final fit = type.id == 'chat' || type.id == 'physical'
        ? BoxFit.cover
        : BoxFit.contain;
    return Image.asset(
      hero,
      width: scale.s(type.heroSize),
      height: scale.s(type.heroSize),
      fit: fit,
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.scale,
    required this.controller,
  });

  final FigmaScale scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;
    final textStyle = AppTypography.inter(
      color: hasValue ? _Tokens.filledTextColor : _Tokens.placeholderColor,
      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
      fontSize: scale.fs(14),
      height: 1,
    );

    return _FeeFieldShell(
      scale: scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scale.s(_Tokens.fieldPadH)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasValue)
              Text(
                '₹ ',
                style: textStyle.copyWith(
                  color: _Tokens.filledTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: textStyle.copyWith(
                  color: _Tokens.filledTextColor,
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  hintStyle: textStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.scale,
    required this.value,
    required this.onTap,
  });

  final FigmaScale scale;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _FeeFieldShell(
        scale: scale,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            scale.s(_Tokens.fieldPadH),
            0,
            scale.s(_Tokens.chevronPadR),
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  hasValue ? value! : 'Select Duration',
                  style: AppTypography.inter(
                    color: hasValue
                        ? _Tokens.filledTextColor
                        : _Tokens.placeholderColor,
                    fontWeight:
                        hasValue ? FontWeight.w600 : FontWeight.w400,
                    fontSize: scale.fs(14),
                    height: 1,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: scale.s(_Tokens.chevronSize),
                color: _Tokens.filledTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.scale,
    required this.controller,
  });

  final FigmaScale scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;

    return _FeeFieldShell(
      scale: scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scale.s(_Tokens.fieldPadH)),
        child: TextField(
          controller: controller,
          style: AppTypography.inter(
            color: _Tokens.filledTextColor,
            fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
            fontSize: scale.fs(14),
            height: 1,
          ),
          decoration: InputDecoration(
            hintText: 'Add Meeting Location',
            hintStyle: AppTypography.inter(
              color: _Tokens.placeholderColor,
              fontWeight: FontWeight.w400,
              fontSize: scale.fs(14),
              height: 1,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    );
  }
}

/// White fee input card — Figma `7125:5510` / `7125:5511` (52px, radius 10).
class _FeeFieldShell extends StatelessWidget {
  const _FeeFieldShell({required this.scale, required this.child});

  final FigmaScale scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: scale.s(_Tokens.fieldH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.s(_Tokens.fieldRadius)),
        boxShadow: const [
          _Tokens.fieldShadow,
          _Tokens.fieldShadow,
        ],
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
