import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_tall_artboard_body.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/payment_success_dynamic_layer.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_drag_to_confirm_button.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Challan payment success — Figma [`7125:4019`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-4019) (360×858).
class UserChallanPaymentSuccessScreen extends StatelessWidget {
  const UserChallanPaymentSuccessScreen({
    super.key,
    required this.payment,
  });

  final UserPaymentResult payment;

  static const _designHeight = 858.0;

  void _onGoToDashboard(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      UserRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      resizeToAvoidBottomInset: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaTallArtboardBody(
        designHeight: _designHeight,
        builder: (context, scale) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppAssets.userChallanPaymentSuccessFull,
                  width: scale.viewportWidth,
                  height: scale.artboardHeight,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.topCenter,
                ),
              ),
              PaymentSuccessDynamicLayer(
                scale: scale,
                payment: payment,
                showAmount: false,
              ),
              Positioned(
                left: scale.s(PaymentSuccessLayout.dragLeft),
                top: scale.s(PaymentSuccessLayout.dragTop),
                width: scale.s(PaymentSuccessLayout.dragWidth),
                height: scale.s(PaymentSuccessLayout.dragHeight),
                child: UserDragToConfirmButton(
                  onComplete: () => _onGoToDashboard(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
