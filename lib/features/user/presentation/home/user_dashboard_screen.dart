import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_premium_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_dashboard_figma_body.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User home — Figma [`7125:1745`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3) (360×800).
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  UserDashboardData? _data;
  String? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await loadUserDashboard();
      final me = await UserRepository.instance.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _data = data;
        _location = me.profile.location;
        _loading = false;
      });
    } on ApiException {
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 0.0;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final topInset = MediaQuery.paddingOf(context).top;

          if (_loading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: _load,
            child: Padding(
              padding: EdgeInsets.only(top: topInset),
              child: UserDashboardFigmaBody(
              scale: s,
              embeddedInShell: widget.embeddedInShell,
              userName: _data?.userName,
              location: _location,
              unreadNotifications: _data?.unreadNotifications ?? 0,
              bottomPadding: bottomPad,
              onWalletTap: () =>
                  Navigator.of(context).pushNamed(UserRoutes.wallet),
              onNotificationsTap: () =>
                  Navigator.of(context).pushNamed(UserRoutes.notifications),
              ),
            ),
          );
        },
      ),
    );
  }
}