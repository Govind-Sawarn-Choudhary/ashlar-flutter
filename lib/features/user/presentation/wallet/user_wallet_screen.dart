import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart'
    show UserPaymentConfig, UserWalletTransaction;
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
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
  String? _errorMessage;
  UserPaymentConfig? _paymentConfig;

  @override
  void initState() {
    super.initState();
    _loadWallet();
    _loadPaymentConfig();
  }

  Future<void> _loadPaymentConfig() async {
    try {
      final config = await UserRepository.instance.getPaymentConfig();
      if (mounted) {
        setState(() => _paymentConfig = config);
      }
    } catch (_) {
      // Default razorpay path if config unavailable.
    }
  }

  String get _filterKey => switch (_filter) {
        UserWalletFilter.all => 'all',
        UserWalletFilter.credit => 'credit',
        UserWalletFilter.debit => 'debit',
      };

  Future<void> _loadWallet() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
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
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Could not load wallet';
        });
      }
    }
  }

  /// Test servers use staging credit; production uses Razorpay when direct top-up is off.
  Future<void> _topUpWallet(double amount) async {
    final preferStaging =
        _paymentConfig?.useStagingWalletTopup != false;

    if (preferStaging) {
      try {
        await UserRepository.instance.addWalletFunds(amount);
        return;
      } on ApiException catch (e) {
        final needsRazorpay = e.statusCode == 400 &&
            e.message.toLowerCase().contains('razorpay');
        if (!needsRazorpay) {
          rethrow;
        }
      }
    }

    if (_paymentConfig != null && _paymentConfig!.razorpayEnabled == false) {
      throw ApiException(
        'Instant test top-up is off on server. Set WALLET_TOPUP_MODE=staging in backend .env, or enable Razorpay.',
      );
    }

    await UserPaymentService.processWalletTopup(amount: amount);
  }

  Future<void> _onAddFunds() async {
    final minTopup = _paymentConfig?.minWalletTopup ?? 100;
    final defaultAmount =
        minTopup >= 500 ? minTopup.toStringAsFixed(0) : '500';
    final controller = TextEditingController(text: defaultAmount);
    final staging = _paymentConfig?.useStagingWalletTopup ?? false;
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UserDesignTokens.surfaceElevated,
        title: const Text('Add funds', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: const TextStyle(color: Colors.white70),
                helperText:
                    'Minimum ₹${minTopup.toStringAsFixed(0)}${staging ? ' · test mode: instant credit' : ' · Razorpay checkout'}',
                helperStyle: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                return;
              }
              if (value < minTopup) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Minimum top-up is ₹${minTopup.toStringAsFixed(0)}',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, value);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null || !mounted) {
      return;
    }

    setState(() => _addingFunds = true);
    try {
      await _topUpWallet(amount);
      await _loadWallet();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('₹${amount.toStringAsFixed(0)} added to wallet')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingFunds = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'My wallet',
        subtitle: 'Top-up & track payments',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: UserDesignTokens.textPrimary),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: UserDesignTokens.gold),
            )
          : RefreshIndicator(
              color: UserDesignTokens.gold,
              onRefresh: _loadWallet,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: UserDesignTokens.goldAccentCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available balance',
                          style: AppTypography.inter(
                            color: UserDesignTokens.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_balance.toStringAsFixed(0)}',
                          style: AppTypography.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: UserDesignTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _addingFunds ? null : _onAddFunds,
                            icon: _addingFunds
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.add, color: Colors.black),
                            label: Text(
                              _addingFunds ? 'Processing…' : 'Add funds',
                              style: AppTypography.inter(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: UserDesignTokens.gold,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (final f in UserWalletFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f.name.toUpperCase()),
                            selected: _filter == f,
                            onSelected: (_) {
                              setState(() => _filter = f);
                              _loadWallet();
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  UserSectionHeader(title: 'Transactions'),
                  if (_errorMessage != null)
                    UserEmptyState(
                      icon: Icons.error_outline,
                      title: 'Could not load',
                      subtitle: _errorMessage!,
                      actionLabel: 'Retry',
                      onAction: _loadWallet,
                    )
                  else if (_transactions.isEmpty)
                    const UserEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle: 'Wallet activity will show up here.',
                    )
                  else
                    ..._transactions.map((tx) {
                      final isCredit = tx.type == 'credit';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: UserDesignTokens.premiumCard(),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isCredit
                                          ? UserDesignTokens.success
                                          : UserDesignTokens.error)
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: isCredit
                                      ? UserDesignTokens.success
                                      : UserDesignTokens.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.description ??
                                          (isCredit ? 'Credit' : 'Debit'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.inter(
                                        fontWeight: FontWeight.w600,
                                        color: UserDesignTokens.textPrimary,
                                      ),
                                    ),
                                    if (tx.createdAt != null)
                                      Text(
                                        tx.createdAt!,
                                        style: AppTypography.inter(
                                          fontSize: 11,
                                          color: UserDesignTokens.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                                style: AppTypography.inter(
                                  fontWeight: FontWeight.w700,
                                  color: isCredit
                                      ? UserDesignTokens.success
                                      : UserDesignTokens.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
