import 'package:ashlar_lawyer_hub/core/notifications/in_app_notification_coordinator.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Slides a premium notification card from the top (in-app, while app is open).
class PremiumInAppNotificationHost extends StatefulWidget {
  const PremiumInAppNotificationHost({super.key, required this.child});

  final Widget child;

  @override
  State<PremiumInAppNotificationHost> createState() =>
      _PremiumInAppNotificationHostState();
}

class _PremiumInAppNotificationHostState extends State<PremiumInAppNotificationHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 260),
    );
    InAppNotificationCoordinator.instance.addListener(_onCoordinator);
  }

  @override
  void dispose() {
    InAppNotificationCoordinator.instance.removeListener(_onCoordinator);
    _slide.dispose();
    super.dispose();
  }

  void _onCoordinator() {
    if (InAppNotificationCoordinator.instance.banner != null) {
      _slide.forward();
    } else {
      _slide.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = InAppNotificationCoordinator.instance.banner;
    return Stack(
      children: [
        widget.child,
        if (item != null)
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic)),
                child: Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) =>
                      InAppNotificationCoordinator.instance.dismiss(),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: InAppNotificationCoordinator.instance.onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A2218), Color(0xFF151515)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              child: Icon(
                                item.categoryIcon,
                                color: const Color(0xFFD4AF37),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  InAppNotificationCoordinator.instance.dismiss,
                              icon: const Icon(Icons.close, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}