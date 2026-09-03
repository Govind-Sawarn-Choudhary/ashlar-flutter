import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_lawyers_search_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User lawyers listing — Figma [`7125:2285`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2285) (360×800).
class UserLawyersScreen extends StatefulWidget {
  const UserLawyersScreen({super.key});

  @override
  State<UserLawyersScreen> createState() => _UserLawyersScreenState();
}

class _UserLawyersScreenState extends State<UserLawyersScreen> {
  final _searchController = TextEditingController();
  List<UserLawyerSummary> _lawyers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLawyers({String? q}) async {
    setState(() => _loading = true);
    try {
      final lawyers = await UserRepository.instance.listLawyers(q: q);
      if (mounted) {
        setState(() {
          _lawyers = lawyers;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _onSearchChanged() {
    _loadLawyers(q: _searchController.text.trim());
  }

  void _onNavTap(UserBottomNavTab tab) {
    switch (tab) {
      case UserBottomNavTab.home:
        Navigator.of(context).pushReplacementNamed(UserRoutes.home);
      case UserBottomNavTab.lawyers:
        break;
      case UserBottomNavTab.documents:
        Navigator.of(context).pushNamed(UserRoutes.documents);
      case UserBottomNavTab.challan:
        Navigator.of(context).pushNamed(UserRoutes.challan);
      case UserBottomNavTab.profile:
        Navigator.of(context).pushNamed(UserRoutes.profile);
    }
  }

  void _openLawyer(UserLawyerSummary lawyer) {
    final contextArg = UserBookingContext(
      lawyerId: lawyer.id,
      lawyerName: lawyer.fullName,
      mode: 'online',
      consultationType: 'chat',
    );

    Navigator.of(context).pushNamed(
      UserRoutes.appointmentPreference,
      arguments: contextArg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userLawyersFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: s.s(15),
                  top: s.s(121),
                  child: UserLawyersSearchBar(
                    scale: s,
                    controller: _searchController,
                  ),
                ),
                Positioned(
                  left: s.s(15),
                  top: s.s(180),
                  right: s.s(15),
                  bottom: s.s(90),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.gold),
                        )
                      : _lawyers.isEmpty
                          ? Center(
                              child: Text(
                                'No approved lawyers yet',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: s.fs(14),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _lawyers.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: s.s(10)),
                              itemBuilder: (context, index) {
                                final lawyer = _lawyers[index];
                                return Material(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(s.s(12)),
                                  child: InkWell(
                                    onTap: () => _openLawyer(lawyer),
                                    borderRadius: BorderRadius.circular(s.s(12)),
                                    child: Padding(
                                      padding: EdgeInsets.all(s.s(14)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lawyer.fullName,
                                                  style: AppTypography.inter(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: s.fs(15),
                                                  ),
                                                ),
                                                if (lawyer.location?.isNotEmpty ==
                                                    true)
                                                  Text(
                                                    lawyer.location!,
                                                    style: AppTypography.inter(
                                                      color: Colors.black54,
                                                      fontSize: s.fs(12),
                                                    ),
                                                  ),
                                                if (lawyer.practiceAreas
                                                        ?.isNotEmpty ==
                                                    true)
                                                  Text(
                                                    lawyer.practiceAreas!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTypography.inter(
                                                      color: AppColors.gold,
                                                      fontSize: s.fs(11),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.black45,
                                            size: s.s(22),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                UserBottomNavHitZones(
                  scale: s,
                  onTap: _onNavTap,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
