import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/notifications/notification_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Notifications — Figma `7125:6603` (360×800).
class LawyerNotificationScreen extends StatefulWidget {
  const LawyerNotificationScreen({super.key});

  @override
  State<LawyerNotificationScreen> createState() =>
      _LawyerNotificationScreenState();
}

class _LawyerNotificationScreenState extends State<LawyerNotificationScreen> {
  bool _pushEnabled = true;
  int _selectedTab = 0;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  static const _panelTop = 174.0;
  static const _panelPad = 12.0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final items = await LawyerMarketplaceRepository.instance.listNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    return _notifications.where((item) {
      final isRead = item['isRead'] as bool? ?? false;
      if (_selectedTab == 1) {
        return !isRead;
      }
      if (_selectedTab == 2) {
        return isRead;
      }
      return true;
    }).toList();
  }

  Future<void> _markAllRead() async {
    try {
      await LawyerMarketplaceRepository.instance.markAllNotificationsRead();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked read')),
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: s.s(25),
                top: s.s(56),
                width: s.s(40),
                height: s.s(40),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Image.asset(
                    AppAssets.walletBackButton,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Positioned(
                left: s.s(149),
                top: s.s(67),
                child: Text(
                  'Notifications',
                  style: NotificationTypography.screenTitle(s),
                ),
              ),
              Positioned(
                left: s.s(25),
                top: s.s(124),
                width: s.s(309),
                height: s.s(28),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: s.s(6.5),
                      child: Text(
                        'Push notifications',
                        style: NotificationTypography.pushLabel(s),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: _PushToggle(
                        scale: s,
                        value: _pushEnabled,
                        onChanged: (v) => setState(() => _pushEnabled = v),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: s.s(25),
                top: s.s(_panelTop),
                width: s.s(309),
                height: s.s(589),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s.s(8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(s.s(8)),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: s.s(309),
                        height: s.s(589),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: s.s(_panelPad),
                              top: s.s(_panelPad),
                              child: _ContentSwitcher(
                                scale: s,
                                selectedIndex: _selectedTab,
                                onChanged: (i) =>
                                    setState(() => _selectedTab = i),
                              ),
                            ),
                            Positioned(
                              left: s.s(_panelPad),
                              top: s.s(67),
                              right: s.s(_panelPad),
                              bottom: s.s(_panelPad + 60),
                              child: _loading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _filteredNotifications.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No notifications',
                                            style: NotificationTypography.tabUnselected(s),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: _filteredNotifications.length,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: s.s(12)),
                                          itemBuilder: (context, index) {
                                            final item = _filteredNotifications[index];
                                            return _ApiNotificationCard(
                                              scale: s,
                                              title: item['title'] as String? ?? '',
                                              body: item['body'] as String? ?? '',
                                              isRead: item['isRead'] as bool? ?? false,
                                            );
                                          },
                                        ),
                            ),
                            Positioned(
                              left: s.s(93),
                              top: s.s(512),
                              child: _MarkAllReadButton(
                                scale: s,
                                onTap: _markAllRead,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _PushToggle extends StatelessWidget {
  const _PushToggle({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  final FigmaScale scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: s.s(45),
        height: s.s(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: value
                ? NotificationTypography.brandGold
                : NotificationTypography.textSecondary,
            borderRadius: BorderRadius.circular(s.s(200)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: value ? s.s(21) : s.s(4),
                top: s.s(4),
                width: s.s(20),
                height: s.s(20),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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

class _ContentSwitcher extends StatelessWidget {
  const _ContentSwitcher({
    required this.scale,
    required this.selectedIndex,
    required this.onChanged,
  });

  final FigmaScale scale;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _tabs = ['All', 'Unread', 'Read'];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: s.s(285),
      height: s.s(39),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NotificationTypography.surfaceComponent,
          borderRadius: BorderRadius.circular(s.s(16)),
        ),
        child: Padding(
          padding: EdgeInsets.all(s.s(4)),
          child: Stack(
            children: [
              Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(i),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s.s(12),
                            vertical: s.s(8),
                          ),
                          decoration: BoxDecoration(
                            color: selectedIndex == i
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(s.s(12)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[i],
                            style: selectedIndex == i
                                ? NotificationTypography.tabSelected(s)
                                : NotificationTypography.tabUnselected(s),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: s.s(285 / 3 * 2 - 0.5),
                top: s.s(14.5),
                child: Container(
                  width: s.s(1),
                  height: s.s(10),
                  color: const Color(0xFFDBDBDB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadIcon extends StatelessWidget {
  const _UnreadIcon({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: s.s(20),
      height: s.s(20),
      child: SvgPicture.asset(
        AppAssets.notificationUnreadIcon,
        width: s.s(14),
        height: s.s(14),
        fit: BoxFit.contain,
        alignment: Alignment.center,
        colorFilter: const ColorFilter.mode(
          NotificationTypography.brandGold,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.scale});

  final FigmaScale scale;

  static const _textBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: s.s(285),
      height: s.s(139),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: NotificationTypography.brandGold,
            width: s.s(1),
          ),
          borderRadius: BorderRadius.circular(s.s(12)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: s.s(16),
              top: s.s(16),
              child: _UnreadIcon(scale: s),
            ),
            Positioned(
              left: s.s(52),
              top: s.s(8),
              width: s.s(217),
              height: s.s(123),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    width: s.s(217),
                    height: s.s(40),
                    child: Text(
                      'Appointment for 02 May\u201926 10:30 am',
                      style: NotificationTypography.cardTitle(s),
                      textHeightBehavior: _textBehavior,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: s.s(44),
                    width: s.s(217),
                    height: s.s(32),
                    child: Text(
                      'Note: You have new appointment for in person meet',
                      style: NotificationTypography.cardBody(s),
                      textHeightBehavior: _textBehavior,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: s.s(80),
                    child: _SmallActionButton(
                      scale: s,
                      label: 'Accept',
                      color: NotificationTypography.brandGold,
                    ),
                  ),
                  Positioned(
                    left: s.s(78),
                    top: s.s(80),
                    child: _SmallActionButton(
                      scale: s,
                      label: 'Reject',
                      color: NotificationTypography.rejectRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.scale});

  final FigmaScale scale;

  static const _textBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: s.s(285),
      height: s.s(119),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: NotificationTypography.brandGold,
            width: s.s(1),
          ),
          borderRadius: BorderRadius.circular(s.s(12)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: s.s(16),
              top: s.s(16),
              child: _UnreadIcon(scale: s),
            ),
            Positioned(
              left: s.s(52),
              top: s.s(19.5),
              width: s.s(217),
              height: s.s(80),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      '1 min. ago',
                      style: NotificationTypography.timestamp(s),
                      textHeightBehavior: _textBehavior,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: s.s(20),
                    width: s.s(217),
                    height: s.s(40),
                    child: Text(
                      'New Message Received\nfrom Fana Sana.',
                      style: NotificationTypography.cardTitle(s),
                      textHeightBehavior: _textBehavior,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: s.s(64),
                    width: s.s(217),
                    height: s.s(16),
                    child: Text(
                      'Hi. Can i get help.',
                      style: NotificationTypography.cardBody(s),
                      textHeightBehavior: _textBehavior,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.scale,
    required this.label,
    required this.color,
  });

  final FigmaScale scale;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: s.s(70),
      height: s.s(26),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: s.s(1.5)),
          borderRadius: BorderRadius.circular(s.s(12)),
        ),
        child: Center(
          child: Text(
            label,
            style: NotificationTypography.actionSmall(s, color),
          ),
        ),
      ),
    );
  }
}

class _ApiNotificationCard extends StatelessWidget {
  const _ApiNotificationCard({
    required this.scale,
    required this.title,
    required this.body,
    required this.isRead,
  });

  final FigmaScale scale;
  final String title;
  final String body;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: NotificationTypography.brandGold,
          width: s.s(1),
        ),
        borderRadius: BorderRadius.circular(s.s(12)),
        color: isRead ? Colors.white : const Color(0xFFFFF9E8),
      ),
      child: Padding(
        padding: EdgeInsets.all(s.s(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: NotificationTypography.cardTitle(s)),
            SizedBox(height: s.s(6)),
            Text(body, style: NotificationTypography.cardBody(s)),
          ],
        ),
      ),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({
    required this.scale,
    required this.onTap,
  });

  final FigmaScale scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: s.s(123),
        height: s.s(37),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: NotificationTypography.brandGold,
              width: s.s(1.5),
            ),
            borderRadius: BorderRadius.circular(s.s(12)),
          ),
          child: Center(
            child: Text(
              'Mark all read',
              style: NotificationTypography.markAllRead(s),
            ),
          ),
        ),
      ),
    );
  }
}
