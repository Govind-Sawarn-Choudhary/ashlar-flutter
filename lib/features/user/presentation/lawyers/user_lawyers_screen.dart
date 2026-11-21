import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserLawyersScreen extends StatefulWidget {
  const UserLawyersScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserLawyersScreen> createState() => _UserLawyersScreenState();
}

class _UserLawyersScreenState extends State<UserLawyersScreen> {
  final _searchController = TextEditingController();
  List<UserLawyerSummary> _lawyers = [];
  bool _loading = true;
  bool _favouritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
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

  List<UserLawyerSummary> get _visibleLawyers {
    if (!_favouritesOnly) {
      return _lawyers;
    }
    return _lawyers.where((l) => l.isFavourite).toList();
  }

  Future<void> _toggleFavourite(UserLawyerSummary lawyer) async {
    try {
      final isFav =
          await UserRepository.instance.toggleFavourite(lawyer.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _lawyers = _lawyers.map((item) {
          if (item.id == lawyer.id) {
            return UserLawyerSummary(
              id: item.id,
              fullName: item.fullName,
              practiceAreas: item.practiceAreas,
              experienceYears: item.experienceYears,
              location: item.location,
              bio: item.bio,
              isFavourite: isFav,
              fees: item.fees,
            );
          }
          return item;
        }).toList();
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _openLawyer(UserLawyerSummary lawyer) {
    Navigator.of(context).pushNamed(
      UserRoutes.appointmentPreference,
      arguments: UserBookingContext(
        lawyerId: lawyer.id,
        lawyerName: lawyer.fullName,
        mode: 'online',
        consultationType: 'chat',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 16.0;

    return UserPremiumScaffold(
      bottomPadding: bottomPad,
      appBar: UserPremiumAppBar(
        title: 'Find a lawyer',
        subtitle: 'Verified advocates near you',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _loadLawyers(q: value.trim()),
              style: AppTypography.inter(color: UserDesignTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or practice area',
                hintStyle: AppTypography.inter(color: UserDesignTokens.textMuted),
                prefixIcon: const Icon(Icons.search, color: UserDesignTokens.gold),
                filled: true,
                fillColor: UserDesignTokens.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () => _loadLawyers(q: _searchController.text.trim()),
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: UserDesignTokens.gold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All lawyers'),
                  selected: !_favouritesOnly,
                  onSelected: (_) => setState(() => _favouritesOnly = false),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Favourites'),
                  selected: _favouritesOnly,
                  onSelected: (_) => setState(() => _favouritesOnly = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: UserDesignTokens.gold),
                  )
                : _visibleLawyers.isEmpty
                    ? UserEmptyState(
                        icon: _favouritesOnly
                            ? Icons.star_outline_rounded
                            : Icons.gavel_outlined,
                        title: _favouritesOnly
                            ? 'No favourites yet'
                            : 'No lawyers available',
                        subtitle: _favouritesOnly
                            ? 'Tap the star on a lawyer to save them here.'
                            : 'Approved lawyers will appear here once onboarded.',
                        actionLabel:
                            _favouritesOnly ? 'Browse lawyers' : 'Refresh',
                        onAction: _favouritesOnly
                            ? () => setState(() => _favouritesOnly = false)
                            : () => _loadLawyers(),
                      )
                    : RefreshIndicator(
                        color: UserDesignTokens.gold,
                        onRefresh: () =>
                            _loadLawyers(q: _searchController.text.trim()),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _visibleLawyers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final lawyer = _visibleLawyers[index];
                            return UserLawyerCard(
                              lawyer: lawyer,
                              onTap: () => _openLawyer(lawyer),
                              onFavourite: () => _toggleFavourite(lawyer),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
