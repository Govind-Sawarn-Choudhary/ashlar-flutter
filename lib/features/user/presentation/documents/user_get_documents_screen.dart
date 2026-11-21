import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

class UserGetDocumentsScreen extends StatefulWidget {
  const UserGetDocumentsScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserGetDocumentsScreen> createState() => _UserGetDocumentsScreenState();
}

class _UserGetDocumentsScreenState extends State<UserGetDocumentsScreen> {
  List<UserDocumentCategory> _categories = [];
  List<UserDocumentOrder> _orders = [];
  bool _loading = true;
  int? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        UserRepository.instance.listDocumentCategories(),
        UserRepository.instance.listDocumentOrders(),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<UserDocumentCategory>;
          _orders = results[1] as List<UserDocumentOrder>;
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
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _purchaseProduct(UserDocumentProduct product) async {
    var payFromWallet = false;
    try {
      final wallet = await UserRepository.instance.getWallet();
      if (wallet.balance >= product.price && mounted) {
        payFromWallet = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: UserDesignTokens.surfaceElevated,
                title: const Text('Pay with wallet?',
                    style: TextStyle(color: Colors.white)),
                content: Text(
                  'Use ₹${product.price.toStringAsFixed(0)} from wallet '
                  '(balance ₹${wallet.balance.toStringAsFixed(0)})?',
                  style: const TextStyle(color: Colors.white70),
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
    } catch (_) {}

    try {
      if (payFromWallet) {
        await UserRepository.instance.purchaseDocument(
          product.id,
          payFromWallet: true,
        );
      } else {
        await UserPaymentService.processDocumentPayment(
          productId: product.id,
          amount: product.price,
          productName: product.name,
        );
      }
      if (!mounted) {
        return;
      }
      await _loadAll();
      if (!mounted) {
        return;
      }
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: UserDesignTokens.surfaceElevated,
          title: const Text('Order placed',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'Your document request is confirmed. Our team will contact you shortly with delivery details.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Widget _buildOrderTile(UserDocumentOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: UserDesignTokens.premiumCard(),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: UserDesignTokens.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: AppTypography.inter(
                    fontWeight: FontWeight.w700,
                    color: UserDesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${order.amount.toStringAsFixed(0)} · Ref ${order.reference}',
                  style: AppTypography.inter(
                    fontSize: 12,
                    color: UserDesignTokens.textMuted,
                  ),
                ),
                if (order.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ordered ${order.createdAt.replaceFirst('T', ' ').substring(0, 16)}',
                    style: AppTypography.inter(
                      fontSize: 11,
                      color: UserDesignTokens.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCategory(UserDocumentCategory category) async {
    if (_expandedCategoryId == category.id) {
      setState(() => _expandedCategoryId = null);
      return;
    }
    setState(() => _expandedCategoryId = category.id);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 16.0;

    return UserPremiumScaffold(
      bottomPadding: bottomPad,
      appBar: const UserPremiumAppBar(
        title: 'Legal documents',
        subtitle: 'Order affidavits, agreements & more',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: UserDesignTokens.gold),
            )
          : _categories.isEmpty && _orders.isEmpty
              ? const UserEmptyState(
                  icon: Icons.description_outlined,
                  title: 'No document categories',
                  subtitle: 'Document services will appear here when available.',
                )
              : RefreshIndicator(
                  color: UserDesignTokens.gold,
                  onRefresh: _loadAll,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (_orders.isNotEmpty) ...[
                        const UserSectionHeader(title: 'My orders'),
                        ..._orders.map(_buildOrderTile),
                        const SizedBox(height: 20),
                      ],
                      const UserSectionHeader(title: 'Browse documents'),
                      if (_categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'New document templates will appear here soon.',
                            style: AppTypography.inter(
                              color: UserDesignTokens.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ...List.generate(_categories.length, (index) {
                          final category = _categories[index];
                          final expanded = _expandedCategoryId == category.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CategoryCard(
                              category: category,
                              expanded: expanded,
                              onTap: () => _toggleCategory(category),
                              onPurchase: _purchaseProduct,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.category,
    required this.expanded,
    required this.onTap,
    required this.onPurchase,
  });

  final UserDocumentCategory category;
  final bool expanded;
  final VoidCallback onTap;
  final ValueChanged<UserDocumentProduct> onPurchase;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  List<UserDocumentProduct> _products = [];
  bool _loadingProducts = false;

  @override
  void didUpdateWidget(covariant _CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded && !oldWidget.expanded) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final products = await UserRepository.instance
          .listDocumentProducts(widget.category.id);
      if (mounted) {
        setState(() {
          _products = products;
          _loadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingProducts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
        child: Ink(
          decoration: UserDesignTokens.premiumCard(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_outlined, color: UserDesignTokens.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: AppTypography.inter(
                            fontWeight: FontWeight.w700,
                            color: UserDesignTokens.textPrimary,
                          ),
                        ),
                        if (widget.category.description?.isNotEmpty == true)
                          Text(
                            widget.category.description!,
                            style: AppTypography.inter(
                              fontSize: 12,
                              color: UserDesignTokens.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    widget.expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: UserDesignTokens.textMuted,
                  ),
                ],
              ),
              if (widget.expanded) ...[
                const SizedBox(height: 12),
                if (_loadingProducts)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: UserDesignTokens.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_products.isEmpty)
                  Text(
                    'No products in this category yet.',
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: UserDesignTokens.textMuted,
                    ),
                  )
                else
                  ..._products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: AppTypography.inter(
                                    fontWeight: FontWeight.w600,
                                    color: UserDesignTokens.textPrimary,
                                  ),
                                ),
                                Text(
                                  '₹${product.price.toStringAsFixed(0)}',
                                  style: AppTypography.inter(
                                    fontSize: 13,
                                    color: UserDesignTokens.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () => widget.onPurchase(product),
                            style: FilledButton.styleFrom(
                              backgroundColor: UserDesignTokens.gold,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Order'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
