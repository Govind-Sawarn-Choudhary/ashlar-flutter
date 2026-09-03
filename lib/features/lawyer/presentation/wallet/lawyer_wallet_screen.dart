import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/wallet/wallet_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// My Wallet — Figma `7125:6270` (360×800).
class LawyerWalletScreen extends StatefulWidget {
  const LawyerWalletScreen({super.key});

  @override
  State<LawyerWalletScreen> createState() => _LawyerWalletScreenState();
}

class _LawyerWalletScreenState extends State<LawyerWalletScreen> {
  double _balance = 0;
  List<UserWalletTransaction> _transactions = [];
  bool _loading = true;
  bool _withdrawing = false;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await LawyerMarketplaceRepository.instance.getWallet();
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

  Future<void> _onWithdrawTap() async {
    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No balance available to withdraw')),
      );
      return;
    }

    final controller = TextEditingController(
      text: _balance.toStringAsFixed(0),
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Withdraw balance', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available: ₹${_balance.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
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
            ],
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null || !mounted) {
      return;
    }

    setState(() => _withdrawing = true);

    try {
      final newBalance =
          await LawyerMarketplaceRepository.instance.withdrawWallet(amount);
      if (!mounted) {
        return;
      }
      setState(() {
        _balance = newBalance;
        _withdrawing = false;
      });
      await _loadWallet();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '₹${amount.toStringAsFixed(0)} withdrawn successfully',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _withdrawing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  static const _scrollTop = 229.0;

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: Stack(
        children: [
          FigmaScreenCanvas(
            builder: (context, s) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: s.s(17),
                    top: s.s(60),
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
                    left: s.s(153),
                    top: s.s(71),
                    child: Text(
                      'My Wallet',
                      style: WalletTypography.title(s),
                    ),
                  ),
                  Positioned(
                    left: s.s(101),
                    top: s.s(138),
                    width: s.s(172),
                    height: s.s(43),
                    child: Center(
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
                              'Rs. ${_balance.toStringAsFixed(0)}',
                              textAlign: TextAlign.center,
                              style: WalletTypography.balance(s),
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    left: s.s(90),
                    top: s.s(190),
                    width: s.s(200),
                    height: s.s(40),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _withdrawing ? null : _onWithdrawTap,
                        borderRadius: BorderRadius.circular(s.s(8)),
                        child: Center(
                          child: Text(
                            _withdrawing
                                ? 'Processing…'
                                : 'Withdraw wallet balance',
                            textAlign: TextAlign.center,
                            style: WalletTypography.withdraw(s),
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: s.s(16),
                    top: s.s(_scrollTop),
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
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      isCredit
                                          ? AppAssets.walletCreditIcon
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
                                                (isCredit
                                                    ? 'Credit'
                                                    : 'Debit'),
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
          if (_withdrawing)
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
