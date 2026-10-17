import 'package:flutter/material.dart';
import 'navigation_sidebar.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final String selectedLabel;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;

  const ResponsiveShell({
    super.key, 
    required this.child, 
    this.selectedLabel = 'Home',
    this.backgroundColor = const Color(0xFFFAF4F0),
    this.resizeToAvoidBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    
    if (!isWide) {
      return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 24),
            SizedBox(
              width: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: NavigationSidebar(selectedLabel: selectedLabel),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: child,
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
