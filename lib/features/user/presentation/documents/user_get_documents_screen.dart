import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_fit_artboard_body.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:flutter/material.dart';

/// Get Documents — Figma [`7125:2483`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2483) (360×870).
class UserGetDocumentsScreen extends StatefulWidget {
  const UserGetDocumentsScreen({super.key});

  @override
  State<UserGetDocumentsScreen> createState() => _UserGetDocumentsScreenState();
}

class _UserGetDocumentsScreenState extends State<UserGetDocumentsScreen> {
  static const _designWidth = 360.0;
  static const _designHeight = 870.0;

  static const _tapPositions = <(double left, double top)>[
    (23, 155),
    (187, 155),
    (23, 327),
    (187, 327),
    (23, 499),
    (187, 499),
    (23, 671),
  ];

  List<UserDocumentCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await UserRepository.instance.listDocumentCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _purchaseProduct(UserDocumentProduct product) async {
    var payFromWallet = false;

    try {
      final wallet = await UserRepository.instance.getWallet();
      if (wallet.balance >= product.price) {
        if (!mounted) {
          return;
        }
        payFromWallet = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pay with wallet?'),
                content: Text(
                  'Use ₹${product.price.toStringAsFixed(0)} from your wallet '
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
    } catch (_) {
      // Continue with direct payment.
    }

    try {
      if (payFromWallet) {
        final result = await UserRepository.instance.purchaseDocument(
          product.id,
          payFromWallet: true,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ordered — ref ${result.reference}',
            ),
          ),
        );
      } else {
        final result = await UserPaymentService.processDocumentPayment(
          productId: product.id,
          amount: product.price,
          productName: product.name,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} ordered — ref ${result.refNumber}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _onCategoryTap(UserDocumentCategory category) async {
    try {
      final products =
          await UserRepository.instance.listDocumentProducts(category.id);
      if (!mounted) {
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final product in products)
                  ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.description ?? ''),
                    trailing: Text('₹${product.price.toStringAsFixed(0)}'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _purchaseProduct(product);
                    },
                  ),
              ],
            ),
          );
        },
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      resizeToAvoidBottomInset: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaFitArtboardBody(
        designWidth: _designWidth,
        designHeight: _designHeight,
        builder: (context, s) {
          final artboardWidth = _designWidth * s.scale;
          return SizedBox(
            width: artboardWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userGetDocumentsFull,
                    width: artboardWidth,
                    height: s.artboardHeight,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                _tapZone(
                  s,
                  left: 22,
                  top: 60,
                  width: 40,
                  height: 40,
                  onTap: () => Navigator.of(context).pop(),
                ),
                for (var i = 0; i < _tapPositions.length; i++)
                  if (i < _categories.length)
                    _tapZone(
                      s,
                      left: _tapPositions[i].$1,
                      top: _tapPositions[i].$2,
                      width: 150,
                      height: 150,
                      onTap: () => _onCategoryTap(_categories[i]),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tapZone(
    FigmaScale s, {
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: s.s(left),
      top: s.s(top),
      width: s.s(width),
      height: s.s(height),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
