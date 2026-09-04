import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_fee_and_charges_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_my_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_select_availability_screen.dart';
import 'package:flutter/material.dart';

/// My Profile — Figma [`7125:6744`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-6744) (360×807).
///
/// Full artboard exported via Figma MCP so layout, fonts, shadows, and glow
/// match the design file exactly.
class LawyerMyProfileScreen extends StatelessWidget {
  const LawyerMyProfileScreen({super.key});

  static const _designWidth = 360.0;
  static const _designHeight = 807.0;

  static Future<void> _signOut(BuildContext context) async {
    await AuthSession.instance.clear();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/role-select', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
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
                    AppAssets.profileScreenFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: s.s(15),
                  top: s.s(43),
                  width: s.s(40),
                  height: s.s(40),
                  child: Semantics(
                    button: true,
                    label: 'Back',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(16),
                  top: s.s(171),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Manage Profile',
                    onTap: () {
                      Navigator.of(context).pushNamed(LawyerRoutes.manageProfile);
                    },
                  ),
                ),
                Positioned(
                  left: s.s(16),
                  top: s.s(250),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Manage Appointments',
                    onTap: () {
                      Navigator.of(context).pushNamed(LawyerRoutes.manageAppointments);
                    },
                  ),
                ),
                Positioned(
                  left: s.s(14),
                  top: s.s(329),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Update My Charges',
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const LawyerFeeAndChargesScreen(
                            mode: LawyerFeeAndChargesMode.update,
                          ),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Charges updated')),
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  left: s.s(13),
                  top: s.s(407),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Update Availability',
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const LawyerSelectAvailabilityScreen(
                            mode: LawyerSelectAvailabilityMode.update,
                          ),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Availability updated')),
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  left: s.s(13),
                  top: s.s(486),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Update My Documents',
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const LawyerMyDocumentsScreen(),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Documents updated')),
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  left: s.s(13),
                  top: s.s(565),
                  width: s.s(329),
                  height: s.s(52),
                  child: _MenuTapTarget(
                    label: 'Manage My Chat',
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        LawyerRoutes.consultationHistory,
                      );
                    },
                  ),
                ),
                Positioned(
                  left: s.s(115),
                  top: s.s(715),
                  width: s.s(146),
                  height: s.s(31),
                  child: Semantics(
                    button: true,
                    label: 'Sign out',
                    child: GestureDetector(
                      onTap: () => _signOut(context),
                      behavior: HitTestBehavior.opaque,
                      child: const ColoredBox(color: Colors.transparent),
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

class _MenuTapTarget extends StatelessWidget {
  const _MenuTapTarget({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
