import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/documents/user_get_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/user_dashboard_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/user_lawyers_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/profile/user_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_shell_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Main user app shell — 5 tabs with shared floating bottom navigation.
class UserMainShellScreen extends StatefulWidget {
  const UserMainShellScreen({
    super.key,
    this.initialTab = UserBottomNavTab.home,
  });

  final UserBottomNavTab initialTab;

  @override
  State<UserMainShellScreen> createState() => _UserMainShellScreenState();
}

class _UserMainShellScreenState extends State<UserMainShellScreen> {
  late UserBottomNavTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _onTabSelected(UserBottomNavTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final scale = FigmaScale.fromViewport(viewport);
    final showBottomNav = ModalRoute.of(context)?.isCurrent ?? true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_selectedTab != UserBottomNavTab.home) {
          setState(() => _selectedTab = UserBottomNavTab.home);
          return;
        }
        SystemNavigator.pop();
      },
      child: UserShellScope(
      switchTab: _onTabSelected,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedTab.index,
              children: const [
                UserDashboardScreen(embeddedInShell: true),
                UserLawyersScreen(embeddedInShell: true),
                UserGetDocumentsScreen(embeddedInShell: true),
                UserChallanScreen(embeddedInShell: true),
                UserProfileScreen(embeddedInShell: true),
              ],
            ),
          ),
          if (showBottomNav)
            UserBottomNavBar(
              scale: scale,
              selectedTab: _selectedTab,
              onTap: _onTabSelected,
            ),
        ],
      ),
    ),
    );
  }
}
