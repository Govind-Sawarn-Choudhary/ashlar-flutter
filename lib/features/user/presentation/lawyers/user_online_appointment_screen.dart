import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_online_appointment_args.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Online appointment via modal — Figma [`7125:2729`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2729) (360×800).
class UserOnlineAppointmentScreen extends StatelessWidget {
  const UserOnlineAppointmentScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  static const _modalLeft = 16.0;
  static const _modalTop = 325.0;
  static const _modalWidth = 329.0;
  static const _modalHeight = 243.0;
  static const _optionLeft = 88.0;
  static const _optionWidth = 152.0;
  static const _optionHeight = 24.0;

  static const _options = <(UserOnlineAppointmentOption, double top)>[
    (UserOnlineAppointmentOption.call, 97),
    (UserOnlineAppointmentOption.videoCall, 134),
    (UserOnlineAppointmentOption.chat, 171),
  ];

  void _onOptionSelected(BuildContext context, UserOnlineAppointmentOption option) {
    final updated = bookingContext.copyWith(
      consultationType: UserBookingContext.consultationTypeFromOption(option),
    );
    Navigator.of(context).pushNamed(
      UserRoutes.lawyerDetail,
      arguments: updated,
    );
  }

  List<Widget> _scrimDismissZones(BuildContext context, FigmaScale s) {
    void dismiss() => Navigator.of(context).pop();

    final modalTop = s.s(_modalTop);
    final modalBottom = s.s(_modalTop + _modalHeight);
    final modalLeft = s.s(_modalLeft);
    final modalRight = s.s(_modalLeft + _modalWidth);

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
      zone(left: 0, top: modalTop, width: modalLeft, height: s.s(_modalHeight)),
      zone(
        left: modalRight,
        top: modalTop,
        right: 0,
        height: s.s(_modalHeight),
      ),
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
                    AppAssets.userOnlineAppointmentFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                ..._scrimDismissZones(context, s),
                for (final option in _options)
                  Positioned(
                    left: s.s(_modalLeft + _optionLeft),
                    top: s.s(_modalTop + option.$2),
                    width: s.s(_optionWidth),
                    height: s.s(_optionHeight),
                    child: GestureDetector(
                      onTap: () => _onOptionSelected(context, option.$1),
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
