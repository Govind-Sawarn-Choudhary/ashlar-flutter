import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/widgets/challan_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Challan Status — Figma [`7125:2125`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2125) (360×800).
///
/// Full artboard PNG + vehicle input field and confirm tap overlay.
class UserChallanScreen extends StatefulWidget {
  const UserChallanScreen({super.key});

  @override
  State<UserChallanScreen> createState() => _UserChallanScreenState();
}

class _UserChallanScreenState extends State<UserChallanScreen> {
  static const _designWidth = 360.0;
  static const _designHeight = 800.0;

  final _vehicleController = TextEditingController();
  final _vehicleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _vehicleFocus.addListener(() => setState(() {}));
    _vehicleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _vehicleFocus.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    final vehicle = _vehicleController.text.trim().toUpperCase();
    if (vehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your vehicle number')),
      );
      return;
    }

    try {
      await UserRepository.instance.lookupChallan(vehicle);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanOtpScreen(vehicleNumber: vehicle),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      resizeToAvoidBottomInset: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        designWidth: _designWidth,
        designHeight: _designHeight,
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.s(_designHeight),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userChallanFull,
                    width: s.viewportWidth,
                    height: s.s(_designHeight),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                _tapZone(
                  s,
                  left: 22,
                  top: 60,
                  width: 40,
                  height: 40,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Positioned(
                  left: s.s(20),
                  top: s.s(167),
                  width: s.s(320),
                  height: s.s(52),
                  child: ChallanTextField(
                    scale: s,
                    controller: _vehicleController,
                    focusNode: _vehicleFocus,
                    hintText: 'Enter Vehicle Number',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s-]')),
                    ],
                  ),
                ),
                Positioned(
                  left: s.s(20),
                  top: s.s(259),
                  width: s.s(324),
                  height: s.s(52),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onConfirm,
                      borderRadius: BorderRadius.circular(s.s(10)),
                      child: const SizedBox.expand(),
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

  Widget _tapZone(
    FigmaScale s, {
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: s.s(left),
      top: s.s(top),
      width: s.s(width),
      height: s.s(height),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
