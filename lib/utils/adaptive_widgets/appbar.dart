import 'dart:io';

import 'package:flutter/material.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    this.leading,
    this.title,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.actions,
  });

  final Widget? leading;

  final Widget? title;

  final bool? centerTitle;

  final bool automaticallyImplyLeading;

  final PreferredSizeWidget? bottom;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      actions: actions,
    );
  }

  @override
  Size get preferredSize {
    if (Platform.isWindows) {
      return Size.fromHeight(50.0 + (bottom == null ? 0 : kTextTabBarHeight));
    } else {
      return Size.fromHeight(
          kToolbarHeight + (bottom == null ? 0 : kTextTabBarHeight));
    }
  }
}
