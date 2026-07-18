import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/l10n.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search', extra: ''),
      child: Container(
        height: 44,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).Search_Coda,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
