import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/consultation/lawyer_consultation_history_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/lawyer_dashboard_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_manage_appointments_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_my_profile_screen.dart';
import 'package:flutter/material.dart';

/// Main lawyer app shell — 4 tabs with a shared floating bottom navigation bar.
class LawyerMainShellScreen extends StatefulWidget {
  const LawyerMainShellScreen({
    super.key,
    this.initialTab = LawyerBottomNavTab.home,
  });

  final LawyerBottomNavTab initialTab;

  @override
  State<LawyerMainShellScreen> createState() => _LawyerMainShellScreenState();
}

class _LawyerMainShellScreenState extends State<LawyerMainShellScreen> {
  late LawyerBottomNavTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _onTabSelected(LawyerBottomNavTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final scale = FigmaScale.fromViewport(viewport);

    return LawyerShellScope(
      switchTab: _onTabSelected,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedTab.index,
              children: const [
                LawyerDashboardScreen(embeddedInShell: true),
                LawyerManageAppointmentsScreen(embeddedInShell: true),
                LawyerConsultationHistoryScreen(embeddedInShell: true),
                LawyerMyProfileScreen(embeddedInShell: true),
              ],
            ),
          ),
          LawyerBottomNavBar(
            scale: scale,
            selectedTab: _selectedTab,
            onTap: _onTabSelected,
          ),
        ],
      ),
    );
  }
}
