import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/community/domain/community_post.dart';

/// Threads/Facebook-style feed post (brief §23-24). Verified veterinary
/// authors get a distinct badge so professional advice is never confused
/// with general community discussion.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onLike, required this.onSave});

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onSave;

  String _relativeTime() {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: post.isVeterinarian ? AppColors.primaryGradient : AppColors.intelligenceGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(post.authorInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(post.authorName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                        if (post.isVeterinarian) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 15, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                        ],
                      ],
                    ),
                    Text(
                      '${post.communityTag} · ${_relativeTime()}',
                      style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                    ),
                  ],
                ),
              ),
              if (post.isVeterinarian)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.08), borderRadius: AppRadius.pillRadius),
                  child: Text('Vet Verified', style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.primaryOnDark : AppColors.primary, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(post.content, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _actionButton(context, post.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded, '${post.likeCount}', onLike, active: post.likedByMe, activeColor: const Color(0xFFF43F5E)),
              const SizedBox(width: AppSpacing.lg),
              _actionButton(
                context,
                Icons.mode_comment_outlined,
                '${post.commentCount}',
                () => AppFeedback.showToast(context, title: 'Comments', message: 'Comment threads arrive in a future update.', type: ToastType.info),
              ),
              const SizedBox(width: AppSpacing.lg),
              _actionButton(
                context,
                Icons.share_outlined,
                '${post.shareCount}',
                () => AppFeedback.showToast(context, title: 'Shared', message: 'Post shared.', type: ToastType.success),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSave,
                icon: Icon(post.savedByMe ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 20, color: post.savedByMe ? (isDark ? AppColors.primaryOnDark : AppColors.primary) : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool active = false, Color? activeColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = active ? activeColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smRadius,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
