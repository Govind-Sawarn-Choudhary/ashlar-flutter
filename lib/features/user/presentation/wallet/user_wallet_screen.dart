import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/wallet/wallet_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum UserWalletFilter { all, credit, debit }

class UserWalletScreen extends StatefulWidget {
  const UserWalletScreen({super.key});

  @override
  State<UserWalletScreen> createState() => _UserWalletScreenState();
}

class _UserWalletScreenState extends State<UserWalletScreen> {
  UserWalletFilter _filter = UserWalletFilter.all;
  double _balance = 0;
  List<UserWalletTransaction> _transactions = [];
  bool _loading = true;
  bool _addingFunds = false;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  String get _filterKey => switch (_filter) {
        UserWalletFilter.all => 'all',
        UserWalletFilter.credit => 'credit',
        UserWalletFilter.debit => 'debit',
      };

  Future<void> _loadWallet() async {
    setState(() => _loading = true);
    try {
      final wallet =
          await UserRepository.instance.getWallet(filter: _filterKey);
      if (mounted) {
        setState(() {
          _balance = wallet.balance;
          _transactions = wallet.transactions;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onFilterChanged(UserWalletFilter value) async {
    setState(() => _filter = value);
    await _loadWallet();
  }

  Future<void> _onAddFunds() async {
    final controller = TextEditingController(text: '1000');

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Add funds', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value == null || value <= 0) {
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (amount == null || !mounted) {
      return;
    }

    setState(() => _addingFunds = true);
    try {
      await UserPaymentService.processWalletTopup(amount: amount);
      if (!mounted) {
        return;
      }
      setState(() => _addingFunds = false);
      await _loadWallet();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('₹${amount.toStringAsFixed(0)} added to wallet')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _addingFunds = false);
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: Stack(
        children: [
          FigmaScreenCanvas(
            builder: (context, s) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.userWalletFull,
                      width: s.viewportWidth,
                      height: s.artboardHeight,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    left: s.s(18),
                    top: s.s(61),
                    width: s.s(40),
                    height: s.s(40),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Image.asset(
                        AppAssets.walletBackButton,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    left: s.s(120),
                    top: s.s(170),
                    child: _loading
                        ? SizedBox(
                            width: s.s(24),
                            height: s.s(24),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.gold,
                            ),
                          )
                        : Text(
                            '₹${_balance.toStringAsFixed(0)}',
                            style: WalletTypography.balance(s),
                          ),
                  ),
                  Positioned(
                    left: s.s(144),
                    top: s.s(183),
                    width: s.s(72),
                    height: s.s(32),
                    child: GestureDetector(
                      onTap: _addingFunds ? null : _onAddFunds,
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                  Positioned(
                    left: s.s(18),
                    top: s.s(224),
                    child: _WalletFilterBar(
                      scale: s,
                      selected: _filter,
                      onChanged: _onFilterChanged,
                    ),
                  ),
                  Positioned(
                    left: s.s(16),
                    top: s.s(270),
                    right: s.s(16),
                    bottom: s.s(24),
                    child: _transactions.isEmpty
                        ? Center(
                            child: Text(
                              'No transactions yet',
                              style: WalletTypography.time(s),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: s.s(8)),
                            itemBuilder: (context, index) {
                              final tx = _transactions[index];
                              final isCredit = tx.type == 'credit';
                              return Container(
                                padding: EdgeInsets.all(s.s(12)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(s.s(10)),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      isCredit
                                          ? AppAssets.userWalletCreditIcon
                                          : AppAssets.userWalletDebitIcon,
                                      width: s.s(28),
                                      height: s.s(28),
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: s.s(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.description ??
                                                (isCredit ? 'Credit' : 'Debit'),
                                            style: WalletTypography.credit(s),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (tx.createdAt != null)
                                            Text(
                                              tx.createdAt!,
                                              style: WalletTypography.time(s),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                                      style: WalletTypography.amount(s).copyWith(
                                        color: isCredit
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          if (_addingFunds)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletFilterBar extends StatelessWidget {
  const _WalletFilterBar({
    required this.scale,
    required this.selected,
    required this.onChanged,
  });

  final FigmaScale scale;
  final UserWalletFilter selected;
  final ValueChanged<UserWalletFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    Widget chip({
      required String label,
      required UserWalletFilter value,
      required double width,
    }) {
      final isSelected = selected == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: s.s(width),
          height: s.s(32),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(s.s(25)),
          ),
          child: Text(
            label,
            style: AppTypography.nunito(
              fontSize: s.fs(14),
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.gold,
              height: 20.02 / 14,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(label: 'All', value: UserWalletFilter.all, width: 54),
        SizedBox(width: s.s(10)),
        chip(label: 'Credit', value: UserWalletFilter.credit, width: 90),
        SizedBox(width: s.s(10)),
        chip(label: 'Debit', value: UserWalletFilter.debit, width: 90),
      ],
    );
  }
}
