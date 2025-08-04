import 'package:flutter/material.dart';
import '../styles/shared_styles.dart';

class FinvuDialog extends StatelessWidget {
  final bool visible;
  final String title;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final Widget child;

  const FinvuDialog({
    super.key,
    required this.visible,
    required this.title,
    required this.onClose,
    required this.onSubmit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: SharedStyles.titleStyle),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onClose, child: const Text('Cancel')),
                const SizedBox(width: 12),
                TextButton(onPressed: onSubmit, child: const Text('Submit')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
