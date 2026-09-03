import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/profile/user_manage_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// My Profile — Figma [`7125:3710`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-3710) (360×807).
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const _designWidth = 360.0;
  static const _designHeight = 807.0;

  static const _manageCardLeft = 16.0;
  static const _manageCardTop = 135.0;
  static const _manageCardWidth = 344.0;
  static const _manageCardHeight = 88.0;

  static const _socialIcons = <(double left, double top, String key)>[
    (60, 307, 'facebook'),
    (113.24, 307, 'whatsapp'),
    (166.48, 307, 'twitter'),
    (221.18, 307, 'linkedin'),
    (274.43, 307, 'telegram'),
  ];

  String _displayName = '';
  String _supportPhone = '+91-3333-333-333';
  Map<String, String> _socialLinks = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await UserRepository.instance.getMe();
      final support = await UserRepository.instance.getSupportInfo();
      if (mounted) {
        setState(() {
          _displayName = me.profile.fullName ?? 'User';
          _supportPhone = support.supportPhone;
          _socialLinks = support.socialLinks;
        });
      }
    } catch (_) {
      // Keep PNG defaults if offline.
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthSession.instance.clear();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/role-select',
      (route) => false,
    );
  }

  Future<void> _openManageProfile(BuildContext context) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const UserManageProfileScreen(),
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (updated == true) {
      await _loadProfile();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  void _openSocial(String key) {
    final url = _socialLinks[key];
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${key[0].toUpperCase()}${key.substring(1)} link not configured')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${key[0].toUpperCase()}${key.substring(1)} link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
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
                    AppAssets.userProfileFull,
                    width: s.viewportWidth,
                    height: s.s(_designHeight),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                if (_displayName.isNotEmpty)
                  Positioned(
                    left: s.s(24),
                    top: s.s(95),
                    right: s.s(24),
                    child: Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: s.fs(18),
                      ),
                    ),
                  ),
                _tapZone(
                  s,
                  left: 15,
                  top: 43,
                  width: 40,
                  height: 40,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _tapZone(
                  s,
                  left: _manageCardLeft,
                  top: _manageCardTop,
                  width: _manageCardWidth,
                  height: _manageCardHeight,
                  onTap: () => _openManageProfile(context),
                ),
                for (final icon in _socialIcons)
                  _tapZone(
                    s,
                    left: icon.$1,
                    top: icon.$2,
                    width: 47.64,
                    height: 49,
                    onTap: () => _openSocial(icon.$3),
                  ),
                _tapZone(
                  s,
                  left: 102,
                  top: 513,
                  width: 156,
                  height: 26,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _supportPhone));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Support: $_supportPhone (copied)')),
                    );
                  },
                ),
                _tapZone(
                  s,
                  left: 115,
                  top: 715,
                  width: 146,
                  height: 31,
                  onTap: () => _signOut(context),
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
