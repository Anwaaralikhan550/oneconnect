import 'package:flutter/material.dart';
import '../widgets/sticky_footer.dart';

mixin FooterNavigationMixin<T extends StatefulWidget> on State<T> {
  int get footerIndex => 0; // Default to home, override in subclasses

  Widget buildWithFooter(Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StickyFooter(
            selectedIndex: footerIndex,
          ),
        ),
      ],
    );
  }

  Widget buildPageWithFooter({
    required Widget body,
    PreferredSizeWidget? appBar,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 129), // Footer height
            child: body,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyFooter(
              selectedIndex: footerIndex,
            ),
          ),
        ],
      ),
    );
  }
}