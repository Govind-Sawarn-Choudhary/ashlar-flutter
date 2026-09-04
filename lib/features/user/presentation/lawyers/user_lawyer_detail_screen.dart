import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_tall_artboard_body.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_drag_to_confirm_button.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Lawyer booking detail — Figma [`7125:2948`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2948) (360×858).
class UserLawyerDetailScreen extends StatefulWidget {
  const UserLawyerDetailScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  @override
  State<UserLawyerDetailScreen> createState() => _UserLawyerDetailScreenState();
}

class _UserLawyerDetailScreenState extends State<UserLawyerDetailScreen> {
  static const _designHeight = 858.0;
  static const _detailPanelLeft = 8.0;
  static const _detailPanelTop = 315.0;

  double? _amount;
  bool _isFavourite = false;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLawyer();
  }

  Future<void> _loadLawyer() async {
    try {
      final lawyer =
          await UserRepository.instance.getLawyer(widget.bookingContext.lawyerId);
      if (!mounted) {
        return;
      }
      setState(() {
        _isFavourite = lawyer.isFavourite;
        _amount = lawyer.feeAmountFor(widget.bookingContext.consultationType) ??
            widget.bookingContext.amount;
        _loading = false;
        _loadError = null;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Could not load lawyer details';
        });
      }
    }
  }

  Future<void> _toggleFavourite() async {
    try {
      final isFavourite = await UserRepository.instance
          .toggleFavourite(widget.bookingContext.lawyerId);
      if (mounted) {
        setState(() => _isFavourite = isFavourite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavourite ? 'Added to favourites' : 'Removed from favourites',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _onBookAppointment(BuildContext context) {
    final amount = _amount ?? 0;
    if (_loadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loadError!)),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation fee is not available. Please try again later.'),
        ),
      );
      return;
    }

    final contextArg = widget.bookingContext.copyWith(amount: amount);
    Navigator.of(context).pushNamed(
      UserRoutes.bookingConfirm,
      arguments: contextArg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaTallArtboardBody(
        designHeight: _designHeight,
        builder: (context, scale) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: scale.viewportWidth,
                height: scale.artboardHeight,
                child: Image.asset(
                  AppAssets.userLawyerDetailFull,
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
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Image.asset(
                    AppAssets.walletBackButton,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: scale.s(303),
                top: scale.s(45),
                width: scale.s(40),
                height: scale.s(40),
                child: GestureDetector(
                  onTap: _toggleFavourite,
                  behavior: HitTestBehavior.opaque,
                ),
              ),
              if (!_loading && _loadError == null)
                Positioned(
                  left: scale.s(24),
                  top: scale.s(360),
                  right: scale.s(24),
                  child: Text(
                    '${widget.bookingContext.lawyerName}\n'
                    '${widget.bookingContext.consultationType.toUpperCase()} · '
                    '₹${(_amount ?? 0).toStringAsFixed(0)}'
                    '${_isFavourite ? ' · ★' : ''}',
                    style: AppTypography.inter(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: scale.fs(13),
                      height: 1.35,
                    ),
                  ),
                ),
              if (_loadError != null)
                Positioned(
                  left: scale.s(24),
                  top: scale.s(360),
                  right: scale.s(24),
                  child: Text(
                    _loadError!,
                    style: AppTypography.inter(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: scale.fs(13),
                      height: 1.35,
                    ),
                  ),
                ),
              Positioned(
                left: scale.s(_detailPanelLeft + 12),
                top: scale.s(_detailPanelTop + 440),
                width: scale.s(324),
                height: scale.s(60),
                child: IgnorePointer(
                  ignoring: _loading || _loadError != null || (_amount ?? 0) <= 0,
                  child: UserDragToConfirmButton(
                    onComplete: () => _onBookAppointment(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
