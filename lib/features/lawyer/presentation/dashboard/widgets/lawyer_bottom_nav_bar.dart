import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:flutter/material.dart';

/// Floating bottom nav docked to the device bottom with a premium pill + shadow.
class LawyerBottomNavBar extends StatelessWidget {
  const LawyerBottomNavBar({
    super.key,
    required this.scale,
    required this.onTap,
    this.selectedTab = LawyerBottomNavTab.home,
  });

  final FigmaScale scale;
  final ValueChanged<LawyerBottomNavTab> onTap;
  final LawyerBottomNavTab selectedTab;

  static const designTop = 724.78125;
  static const _navHeight = 57.0;

  static const _items = [
    (LawyerBottomNavTab.home, Icons.home_rounded, 'Home'),
    (LawyerBottomNavTab.appointments, Icons.event_note_rounded, 'My Appointments'),
    (LawyerBottomNavTab.chatHistory, Icons.chat_bubble_outline_rounded, 'Chat History'),
    (LawyerBottomNavTab.profile, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final height = s.s(_navHeight);
    final radius = height / 2;

    return Positioned(
      left: s.s(16),
      right: s.s(16),
      bottom: bottomInset + s.s(12),
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _NavItem(
                    scale: s,
                    icon: item.$2,
                    label: item.$3,
                    selected: selectedTab == item.$1,
                    onTap: () => onTap(item.$1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.scale,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FigmaScale scale;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = selected ? AppColors.gold : const Color(0xFF92929D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: s.s(6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: s.s(20), color: color),
              SizedBox(height: s.s(2)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: s.fs(9),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
