import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/index.dart';

/// Glassmorphism style statistic card with premium styling
class StatCard extends StatelessWidget {
  /// Card title/label
  final String label;

  /// Statistic value to display
  final String value;

  /// Optional icon to display
  final IconData? icon;

  /// Icon color
  final Color iconColor;

  /// Background gradient
  final Gradient? gradient;

  /// On card tap callback
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor = AppColors.constructionGold,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md16),
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white.withValues(alpha: 0.1),
                      AppColors.white.withValues(alpha: 0.05),
                    ],
                  ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header with icon and label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.slateGrey,
                          fontSize: AppTypography.fontSize14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor.withValues(alpha: 0.2),
                        ),
                        child: Icon(icon, size: 20, color: iconColor),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm12),
                // Value display
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: AppTypography.bold,
                    color: AppColors.deepNavy,
                    fontSize: AppTypography.fontSize28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension method to easily create gradient variants
extension StatCardGradients on StatCard {
  static Gradient getGradientForType(String type) {
    switch (type) {
      case 'active':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.infoBlue.withValues(alpha: 0.15),
            AppColors.infoBlue.withValues(alpha: 0.05),
          ],
        );
      case 'overdue':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.errorRed.withValues(alpha: 0.15),
            AppColors.errorRed.withValues(alpha: 0.05),
          ],
        );
      case 'sites':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.successGreen.withValues(alpha: 0.15),
            AppColors.successGreen.withValues(alpha: 0.05),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.constructionGold.withValues(alpha: 0.15),
            AppColors.constructionGold.withValues(alpha: 0.05),
          ],
        );
    }
  }
}
