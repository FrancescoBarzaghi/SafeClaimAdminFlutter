import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/user_model.dart';

BoxDecoration safeClaimCardDecoration({
  Color color = SafeClaimColors.card,
  double radius = 16,
  bool elevated = false,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: SafeClaimColors.primaryLight),
    boxShadow: elevated
        ? [
            BoxShadow(
              color: SafeClaimColors.foreground.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ]
        : null,
  );
}

BoxDecoration safeClaimStatusDecoration({
  Color background = SafeClaimColors.primaryLightest,
  Color border = SafeClaimColors.primaryLight,
  double radius = 8,
}) {
  return BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );
}

class SafeClaimRoleBadge extends StatelessWidget {
  final UserRole role;
  final bool compact;
  final Color? backgroundColor;
  final Color? textColor;

  const SafeClaimRoleBadge({
    super.key,
    required this.role,
    this.compact = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = roleConfig[role]!;
    final effectiveBackground = backgroundColor ?? cfg.bg;
    final effectiveText = textColor ?? cfg.text;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: safeClaimStatusDecoration(
        background: effectiveBackground,
        border: effectiveText.withValues(alpha: 0.45),
        radius: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: compact ? 14 : 16, color: effectiveText),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: TextStyle(
              color: effectiveText,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SafeClaimActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SafeClaimActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(onPressed: onPressed, child: child),
    );
  }
}
