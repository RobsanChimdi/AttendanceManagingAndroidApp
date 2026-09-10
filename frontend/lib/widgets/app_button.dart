import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Professional button components following Material 3 guidelines
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonType type;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.type = ButtonType.primary,
    this.icon,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = _buildPrimaryButton(context, isDisabled);
        break;
      case ButtonType.secondary:
        button = _buildSecondaryButton(context, isDisabled);
        break;
      case ButtonType.outline:
        button = _buildOutlineButton(context, isDisabled);
        break;
      case ButtonType.text:
        button = _buildTextButton(context, isDisabled);
        break;
      case ButtonType.danger:
        button = _buildDangerButton(context, isDisabled);
        break;
    }
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        side: BorderSide(
          color: isDisabled ? AppColors.textDisabled : AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final children = <Widget>[];
    
    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: AppSpacing.sm));
    }
    
    children.add(Text(text, style: AppTextStyles.button));
    
    if (trailing != null) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(trailing!);
    } else if (icon != null) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(Icon(icon, size: 18));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}
