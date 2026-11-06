import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/presentation/widgets/post_comments_sheet.dart';

/// Threads/Facebook-style feed post. Verified veterinary authors get a distinct
/// badge so professional advice is clearly recognizable.
///
/// Designed with Canivue's warm sanctuary cards, Plus Jakarta Sans,
/// and smooth interactive chips.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    this.onComment,
    this.onTopicTap,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback? onComment;
  final ValueChanged<String>? onTopicTap;

  String _relativeTime() {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Color _topicColor(String tag, bool isDark) {
    if (tag.contains('Allergies')) {
      return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7A67EE);
    } else if (tag.contains('Arthritis')) {
      return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    } else if (tag.contains('Obesity')) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E);
    } else if (tag.contains('Digestive')) {
      return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  Color _topicBackground(String tag, bool isDark) {
    if (tag.contains('Allergies')) {
      return isDark ? const Color(0x228B5CF6) : AppColors.pastelLilac;
    } else if (tag.contains('Arthritis')) {
      return isDark ? const Color(0x220284C7) : AppColors.pastelSky;
    } else if (tag.contains('Obesity')) {
      return isDark ? const Color(0x2210B981) : AppColors.pastelMint;
    } else if (tag.contains('Digestive')) {
      return isDark ? const Color(0x22F59E0B) : AppColors.pastelAmber;
    }
    return isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9);
  }

  void _showShareOptions(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1720) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Share Post',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.copy_rounded, color: Color(0xFF0F766E), size: 20),
                ),
                title: Text(
                  'Copy Link & Post Text',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Copies text snippet directly to clipboard',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Clipboard.setData(ClipboardData(text: '${post.authorName} on Canivue: "${post.content}"'));
                  AppFeedback.showToast(
                    context,
                    title: 'Copied to Clipboard 📋',
                    message: 'Post link is ready to paste anywhere.',
                    type: ToastType.success,
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x228B5CF6) : AppColors.pastelLilac,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF7A67EE), size: 18),
                ),
                title: Text(
                  'Send via Vet Telehealth Chat',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Share into your active doctor conversation',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AppFeedback.showToast(
                    context,
                    title: 'Shared to Vet Chat 🩺',
                    message: 'Post forwarded into doctor discussion.',
                    type: ToastType.success,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author & Metadata Row
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  gradient: post.isVeterinarian
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (post.isVeterinarian ? AppColors.primary : const Color(0xFF6366F1))
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    post.authorInitials,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.isVeterinarian) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onTopicTap != null ? () => onTopicTap!(post.communityTag) : null,
                          child: Text(
                            post.communityTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _topicColor(post.communityTag, isDark),
                            ),
                          ),
                        ),
                        Text(
                          ' · ${_relativeTime()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (post.isVeterinarian)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2210B981) : AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0x4410B981) : const Color(0xFFBFE7DC),
                    ),
                  ),
                  child: Text(
                    '🩺 Vet Verified',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Community Topic Pill Tag
          GestureDetector(
            onTap: onTopicTap != null ? () => onTopicTap!(post.communityTag) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _topicBackground(post.communityTag, isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '# ${post.communityTag}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _topicColor(post.communityTag, isDark),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 9,
                    color: _topicColor(post.communityTag, isDark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Post Content Body
          Text(
            post.content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 14),

          // Action Chips Row (Like, Comment, Share, Save)
          Row(
            children: [
              _actionChip(
                context,
                icon: post.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: '${post.likeCount}',
                onTap: () {
                  HapticFeedback.selectionClick();
                  onLike();
                },
                active: post.likedByMe,
                activeColor: const Color(0xFFF43F5E),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _actionChip(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.commentCount}',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onComment != null) {
                    onComment!();
                  } else {
                    PostCommentsSheet.show(context, post);
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _actionChip(
                context,
                icon: Icons.share_outlined,
                label: '${post.shareCount}',
                onTap: () => _showShareOptions(context),
                isDark: isDark,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onSave();
                  AppFeedback.showToast(
                    context,
                    title: post.savedByMe ? 'Removed' : 'Saved 🔖',
                    message: post.savedByMe
                        ? 'Post removed from your saved list.'
                        : 'Post saved to your bookmarks.',
                    type: ToastType.info,
                  );
                },
                icon: Icon(
                  post.savedByMe ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: post.savedByMe
                      ? (isDark ? AppColors.primaryOnDark : AppColors.primary)
                      : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool active = false,
    Color? activeColor,
  }) {
    final color = active
        ? (activeColor ?? (isDark ? AppColors.primaryOnDark : AppColors.primary))
        : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF6F4EE)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
