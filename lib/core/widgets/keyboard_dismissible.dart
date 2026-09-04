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
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: (padding ?? EdgeInsets.zero).add(
        EdgeInsets.only(bottom: keyboardInset > 0 ? keyboardInset + 16 : safeBottom),
      ),
      child: child,
    );
  }
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
