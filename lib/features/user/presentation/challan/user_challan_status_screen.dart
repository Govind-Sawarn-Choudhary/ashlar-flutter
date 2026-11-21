import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_payment_success_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/widgets/challan_filter_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

class UserChallanStatusScreen extends StatefulWidget {
  const UserChallanStatusScreen({
    super.key,
    required this.vehicleNumber,
    required this.mobileNumber,
  });

  final String vehicleNumber;
  final String mobileNumber;

  @override
  State<UserChallanStatusScreen> createState() => _UserChallanStatusScreenState();
}

class _UserChallanStatusScreenState extends State<UserChallanStatusScreen> {
  UserChallanFilter _filter = UserChallanFilter.pending;
  List<UserChallanItem> _challans = [];
  bool _loading = true;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  Future<void> _loadChallans() async {
    setState(() => _loading = true);
    try {
      final challans = await UserRepository.instance.listChallans(
        vehicleNumber: widget.vehicleNumber,
      );
      if (mounted) {
        setState(() {
          _challans = challans;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String get _statusKey => switch (_filter) {
        UserChallanFilter.pending => 'pending',
        UserChallanFilter.inProgress => 'in_progress',
        UserChallanFilter.settled => 'settled',
      };

  List<UserChallanItem> get _filteredChallans =>
      _challans.where((c) => c.status == _statusKey).toList();

  Future<void> _payChallan(UserChallanItem challan) async {
    if (_paying) {
      return;
    }
    setState(() => _paying = true);
    try {
      var payFromWallet = false;
      final wallet = await UserRepository.instance.getWallet();
      if (wallet.balance >= challan.amount && mounted) {
        payFromWallet = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pay with wallet?'),
                content: Text(
                  'Use ₹${challan.amount.toStringAsFixed(0)} from wallet '
                  '(balance ₹${wallet.balance.toStringAsFixed(0)})?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Pay directly'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Use wallet'),
                  ),
                ],
              ),
            ) ??
            false;
      }

      UserPaymentResult payment;
      if (payFromWallet) {
        final result = await UserRepository.instance.payChallan(
          challan.id,
          challan.amount,
          payFromWallet: true,
        );
        payment = UserPaymentResult(
          isSuccess: true,
          amount: result.amount,
          refNumber: result.reference,
          paymentTime: result.paymentTime,
        );
      } else {
        payment = await UserPaymentService.processChallanPayment(
          challanId: challan.id,
          amount: challan.amount,
          title: challan.title,
        );
      }

      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanPaymentSuccessScreen(payment: payment),
        ),
      );
      await _loadChallans();
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
        setState(() => _paying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'Challan status',
        subtitle: widget.vehicleNumber,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: UserDesignTokens.textPrimary, size: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Pending',
                  selected: _filter == UserChallanFilter.pending,
                  onTap: () => setState(() => _filter = UserChallanFilter.pending),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'In progress',
                  selected: _filter == UserChallanFilter.inProgress,
                  onTap: () => setState(() => _filter = UserChallanFilter.inProgress),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Settled',
                  selected: _filter == UserChallanFilter.settled,
                  onTap: () => setState(() => _filter = UserChallanFilter.settled),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: UserDesignTokens.gold),
                  )
                : _filteredChallans.isEmpty
                    ? UserEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No challans here',
                        subtitle: _filter == UserChallanFilter.pending
                            ? 'No pending fines for this vehicle.'
                            : 'Nothing to show in this category.',
                        actionLabel: 'Refresh',
                        onAction: _loadChallans,
                      )
                    : RefreshIndicator(
                        color: UserDesignTokens.gold,
                        onRefresh: _loadChallans,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _filteredChallans.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final challan = _filteredChallans[index];
                            return _ChallanCard(
                              challan: challan,
                              canPay: _filter == UserChallanFilter.pending,
                              paying: _paying,
                              onPay: () => _payChallan(challan),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: UserDesignTokens.goldSoft,
      checkmarkColor: UserDesignTokens.gold,
    );
  }
}

class _ChallanCard extends StatelessWidget {
  const _ChallanCard({
    required this.challan,
    required this.canPay,
    required this.paying,
    required this.onPay,
  });

  final UserChallanItem challan;
  final bool canPay;
  final bool paying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserDesignTokens.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challan.title,
            style: AppTypography.inter(
              fontWeight: FontWeight.w700,
              color: UserDesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${challan.amount.toStringAsFixed(0)} · ${challan.status.replaceAll('_', ' ')}',
            style: AppTypography.inter(
              fontSize: 13,
              color: UserDesignTokens.textMuted,
            ),
          ),
          if (canPay) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: paying ? null : onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: UserDesignTokens.gold,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  paying ? 'Processing…' : 'Pay now',
                  style: AppTypography.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
