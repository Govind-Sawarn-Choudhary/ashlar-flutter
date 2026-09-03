import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Appointment preference modal — Figma [`7125:2519`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2519) (360×800).
class UserAppointmentPreferenceScreen extends StatelessWidget {
  const UserAppointmentPreferenceScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  static const _modalLeft = 17.0;
  static const _modalTop = 326.0;
  static const _onlineLeft = 68.0;
  static const _offlineLeft = 169.0;
  static const _buttonTop = 86.0;
  static const _buttonWidth = 92.0;
  static const _buttonHeight = 24.0;

  void _onOnlineTap(BuildContext context) {
    Navigator.of(context).pushNamed(
      UserRoutes.onlineAppointment,
      arguments: bookingContext.copyWith(mode: 'online'),
    );
  }

  void _onOfflineTap(BuildContext context) {
    Navigator.of(context).pushNamed(
      UserRoutes.lawyerDetail,
      arguments: bookingContext.copyWith(
        mode: 'offline',
        consultationType: 'physical',
      ),
    );
  }

  List<Widget> _scrimDismissZones(BuildContext context, FigmaScale s) {
    void dismiss() => Navigator.of(context).pop();

    final modalTop = s.s(_modalTop);
    final modalBottom = s.s(_modalTop + 146);
    final modalLeft = s.s(_modalLeft);
    final modalRight = s.s(_modalLeft + 329);

    Widget zone({
      required double left,
      required double top,
      double? width,
      double? height,
      double? right,
      double? bottom,
    }) {
      return Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: dismiss,
          behavior: HitTestBehavior.opaque,
        ),
      );
    }

    return [
      zone(left: 0, top: 0, right: 0, height: modalTop),
      zone(left: 0, top: modalBottom, right: 0, bottom: 0),
      zone(left: 0, top: modalTop, width: modalLeft, height: s.s(146)),
      zone(left: modalRight, top: modalTop, right: 0, height: s.s(146)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userAppointmentPreferenceFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                ..._scrimDismissZones(context, s),
                Positioned(
                  left: s.s(_modalLeft + _onlineLeft),
                  top: s.s(_modalTop + _buttonTop),
                  width: s.s(_buttonWidth),
                  height: s.s(_buttonHeight),
                  child: GestureDetector(
                    onTap: () => _onOnlineTap(context),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Positioned(
                  left: s.s(_modalLeft + _offlineLeft),
                  top: s.s(_modalTop + _buttonTop),
                  width: s.s(_buttonWidth),
                  height: s.s(_buttonHeight),
                  child: GestureDetector(
                    onTap: () => _onOfflineTap(context),
                    behavior: HitTestBehavior.opaque,
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
