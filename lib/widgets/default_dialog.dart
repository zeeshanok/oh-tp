import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void showAnimatedDialog(BuildContext context, WidgetBuilder builder) {
  showGeneralDialog(
    context: context,
    transitionDuration: 250.ms,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: Tween(begin: 0.5, end: 1.0).animate(animation),
          curve: Curves.easeOutCubic,
        ),
        child: child,
      ),
    ),
    anchorPoint: Offset.zero,
  );
}

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({super.key, required this.content, required this.title});

  final Widget content;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            content,
          ],
        ),
      ),
    );
  }
}
