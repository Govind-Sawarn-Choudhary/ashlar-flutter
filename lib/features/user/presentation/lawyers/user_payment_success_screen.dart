import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_tall_artboard_body.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/payment_success_dynamic_layer.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_drag_to_confirm_button.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Payment success / wallet — Figma [`7125:3399`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-3399) (360×858).
class UserPaymentSuccessScreen extends StatelessWidget {
  const UserPaymentSuccessScreen({
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

  void _onStartConsultation(BuildContext context) {
    if (!payment.canStartOnlineConsultation) {
      _onGoToDashboard(context);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      UserRoutes.consultation,
      (route) => route.settings.name == UserRoutes.home,
      arguments: ConsultationScreenArgs(
        appointmentId: payment.appointmentId!,
        isLawyer: false,
        peerName: payment.lawyerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onGoToDashboard(context);
        }
      },
      child: AppDarkScaffold(
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
                    AppAssets.userPaymentSuccessFull,
                    width: scale.viewportWidth,
                    height: scale.artboardHeight,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  left: scale.s(15),
                  top: scale.s(43),
                  width: scale.s(40),
                  height: scale.s(40),
                  child: GestureDetector(
                    onTap: () => _onGoToDashboard(context),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                PaymentSuccessDynamicLayer(
                  scale: scale,
                  payment: payment,
                ),
                Positioned(
                  left: scale.s(PaymentSuccessLayout.dragLeft),
                  top: scale.s(PaymentSuccessLayout.dragTop),
                  width: scale.s(PaymentSuccessLayout.dragWidth),
                  height: scale.s(PaymentSuccessLayout.dragHeight),
                  child: UserDragToConfirmButton(
                    onComplete: () => payment.canStartOnlineConsultation
                        ? _onStartConsultation(context)
                        : _onGoToDashboard(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
