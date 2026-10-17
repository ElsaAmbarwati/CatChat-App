import 'package:flutter/material.dart';

class ConstrainedScaffold extends StatelessWidget {
  final Widget? body;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? floatingActionButton;

  const ConstrainedScaffold({
    super.key,
    this.body,
    this.backgroundColor,
    this.appBar,
    this.resizeToAvoidBottomInset,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
    );
  }
}
