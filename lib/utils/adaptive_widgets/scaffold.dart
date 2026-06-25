import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({this.body, this.appBar, super.key});

  final Widget? body;

  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: appBar,
      body: body,
    );
  }
}
