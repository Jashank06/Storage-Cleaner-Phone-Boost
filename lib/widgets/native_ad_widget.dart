import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Native Ad Widget Placeholder
/// Replace with actual AdMob native ad when ready
class NativeAdWidget extends StatelessWidget {
  final double height;
  
  const NativeAdWidget({
    super.key,
    this.height = 100,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ad_units,
              color: AppTheme.textGrey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Ad Placeholder',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Integrate AdMob here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
