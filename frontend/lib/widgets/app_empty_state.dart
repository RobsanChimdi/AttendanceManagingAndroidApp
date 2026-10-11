import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Professional empty state component
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                type: ButtonType.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for no data
class NoDataEmptyState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const NoDataEmptyState({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No Data Available',
      message: message ?? 'There are no records to display at this time.',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }
}

/// Empty state for no search results
class NoSearchResultsEmptyState extends StatelessWidget {
  final String? message;

  const NoSearchResultsEmptyState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: message ?? 'Try adjusting your search or filters.',
    );
  }
}

/// Empty state for no internet
class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetEmptyState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
