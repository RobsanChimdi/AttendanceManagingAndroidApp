import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Status badge component for displaying status indicators
class AppStatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool isSmall;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.sm : AppSpacing.md,
        vertical: isSmall ? AppSpacing.xs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: isSmall ? 12 : 14,
            color: config.textColor,
          ),
          if (!isSmall) const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (type) {
      case StatusType.present:
        return _StatusConfig(
          backgroundColor: AppColors.success.withOpacity(0.1),
          textColor: AppColors.success,
          borderColor: AppColors.success,
          icon: Icons.check_circle,
        );
      case StatusType.absent:
        return _StatusConfig(
          backgroundColor: AppColors.error.withOpacity(0.1),
          textColor: AppColors.error,
          borderColor: AppColors.error,
          icon: Icons.cancel,
        );
      case StatusType.warning:
        return _StatusConfig(
          backgroundColor: AppColors.warning.withOpacity(0.1),
          textColor: AppColors.warning,
          borderColor: AppColors.warning,
          icon: Icons.warning,
        );
      case StatusType.info:
        return _StatusConfig(
          backgroundColor: AppColors.info.withOpacity(0.1),
          textColor: AppColors.info,
          borderColor: AppColors.info,
          icon: Icons.info,
        );
      case StatusType.neutral:
        return _StatusConfig(
          backgroundColor: AppColors.surfaceVariant,
          textColor: AppColors.textSecondary,
          borderColor: AppColors.border,
          icon: Icons.circle,
        );
    }
  }
}

enum StatusType {
  present,
  absent,
  warning,
  info,
  neutral,
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}
