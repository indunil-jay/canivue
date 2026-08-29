import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// WhatsApp-style chat bubble (brief §3, §26). Sent messages align right in
/// the primary teal; received messages align left on a neutral surface.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.timeLabel,
    this.statusIcon,
  });

  final String text;
  final bool isMine;
  final String timeLabel;

  /// e.g. a small check/double-check icon for sent/delivered/read.
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = isMine
        ? (isDark ? AppColors.primaryOnDark : AppColors.primary)
        : (isDark ? AppColors.darkElevatedSurface : AppColors.lightCard);
    final textColor = isMine ? (isDark ? const Color(0xFF04211D) : Colors.white) : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final metaColor = isMine ? textColor.withValues(alpha: 0.7) : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: textColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timeLabel, style: theme.textTheme.labelSmall?.copyWith(color: metaColor, fontSize: 10)),
                if (statusIcon != null) ...[
                  const SizedBox(width: 3),
                  Icon(statusIcon, size: 12, color: metaColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
