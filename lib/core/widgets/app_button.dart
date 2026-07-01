import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import 'package:wassali/core/theme/color_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, success }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final bool isLeadingIcon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.isLeadingIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getForegroundColor();
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && isLeadingIcon) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle.copyWith(color: foregroundColor)),
              if (icon != null && !isLeadingIcon) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 20),
              ],
            ],
          );

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 80),
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                variant == AppButtonVariant.secondary ? 10 : 14,
              ),
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.pressed)
                  ? foregroundColor.withOpacity(0.12)
                  : null,
            ),
          ),
          child: content,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return ColorTokens.secondary;
      case AppButtonVariant.secondary:
        return Colors.white;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return ColorTokens.error;
      case AppButtonVariant.success:
        return ColorTokens.accent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.secondary:
        return ColorTokens.secondary;
      case AppButtonVariant.ghost:
        return ColorTokens.textSecondary;
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
      case AppButtonVariant.success:
        return Colors.white;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }
}


