import 'package:flutter/material.dart';

/// Dismisses the keyboard when the user taps outside focused fields.
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({
    super.key,
    required this.child,
  });

  final Widget child;

  static void dismiss(BuildContext context) {
    final focusScope = FocusScope.of(context);
    if (!focusScope.hasPrimaryFocus && focusScope.focusedChild != null) {
      focusScope.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => dismiss(context),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Scrollable form area that lifts content above the keyboard.
class KeyboardAwareScrollView extends StatelessWidget {
  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.stickyFooter = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  /// When true, a sticky footer handles keyboard/safe-area insets — avoid
  /// double-padding here (used with [stickyFooterPadding] on the footer).
  final bool stickyFooter;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: (padding ?? EdgeInsets.zero).add(
        EdgeInsets.only(
          bottom: stickyFooter
              ? 12
              : (keyboardInset > 0 ? keyboardInset + 16 : safeBottom),
        ),
      ),
      child: child,
    );
  }
}

/// Padding for a bottom action bar that clears the system navigation bar.
///
/// With [AppDarkScaffold.resizeToAvoidBottomInset], the keyboard already
/// shrinks the body — do not add viewInsets here.
EdgeInsets stickyFooterPadding(
  BuildContext context, {
  double horizontal = 20,
  double top = 8,
  double extra = 16,
}) {
  final safeBottom = MediaQuery.paddingOf(context).bottom;

  return EdgeInsets.fromLTRB(
    horizontal,
    top,
    horizontal,
    safeBottom + extra,
  );
}

/// Scrolls the focused field into view when the keyboard opens.
mixin FormFieldScrollMixin<T extends StatefulWidget> on State<T> {
  ScrollController? get formScrollController;

  void ensureFieldVisible(BuildContext fieldContext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }
}
