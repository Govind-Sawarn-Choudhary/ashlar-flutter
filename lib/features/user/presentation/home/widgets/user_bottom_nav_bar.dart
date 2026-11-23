import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:flutter/material.dart';

/// Floating premium bottom navigation for the user app.
class UserBottomNavBar extends StatelessWidget {
  const UserBottomNavBar({
    super.key,
    required this.scale,
    required this.onTap,
    this.selectedTab = UserBottomNavTab.home,
  });

  final FigmaScale scale;
  final ValueChanged<UserBottomNavTab> onTap;
  final UserBottomNavTab selectedTab;

  static const _navHeight = 62.0;

  static double reservedBottomPadding(
    BuildContext context, {
    FigmaScale? scale,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navHeight = scale?.s(_navHeight) ?? _navHeight;
    return navHeight + bottomInset + (scale?.s(20) ?? 20);
  }

  static const _items = [
    (UserBottomNavTab.home, Icons.home_rounded, 'Home'),
    (UserBottomNavTab.lawyers, Icons.gavel_rounded, 'Lawyers'),
    (UserBottomNavTab.documents, Icons.description_outlined, 'Get Documents'),
    (UserBottomNavTab.challan, Icons.directions_car_outlined, 'Challan Pay'),
    (UserBottomNavTab.profile, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final height = s.s(_navHeight);
    final radius = height / 2;

    return Positioned(
      left: s.s(12),
      right: s.s(12),
      bottom: bottomInset + s.s(10),
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
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
    final color = selected ? Colors.black : const Color(0xFF9E9E9E);

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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.inter(
                    fontSize: s.fs(9),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
