import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/messages/presentation/controllers/messaging_controller.dart';
import 'package:canivue/features/messages/presentation/screens/chat_screen.dart';

/// Owner shell "Messages" tab — veterinary conversations & consultations.
///
/// Refined with Canivue's warm sanctuary styling, tactile card geometry,
/// active status indicators, and Apple-grade fluid typography.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Editorial Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(context, isDark),
              ),

              // 2. Conversation List
              Expanded(
                child: conversationsAsync.when(
                  loading: () => ListView(
                    padding: const EdgeInsets.all(20),
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: SkeletonBox(height: 80, borderRadius: BorderRadius.all(Radius.circular(22))),
                      ),
                    ),
                  ),
                  error: (_, _) => ErrorState(
                    message: "We couldn't load your messages.",
                    onRetry: () => ref.invalidate(conversationsProvider),
                  ),
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return const EmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'No consultations yet',
                        message: 'Direct messages with your veterinary care team will appear here.',
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(conversation: conversation),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar with online status badge
                                    Stack(
                                      children: [
                                        Container(
                                          height: 52,
                                          width: 52,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              conversation.vetInitials,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (conversation.online)
                                          Positioned(
                                            right: 2,
                                            bottom: 2,
                                            child: Container(
                                              height: 14,
                                              width: 14,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark ? AppColors.darkCard : Colors.white,
                                                  width: 2.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  conversation.vetName,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF10B981)),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            conversation.lastMessagePreview,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: conversation.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                                              color: conversation.unreadCount > 0
                                                  ? (isDark ? Colors.white : const Color(0xFF181A20))
                                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat('h:mm a').format(conversation.lastMessageAt),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                          ),
                                        ),
                                        if (conversation.unreadCount > 0) ...[
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${conversation.unreadCount}',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0x4414B8A6) : const Color(0xFFBFE7DC),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      'TELEHEALTH CARE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Consultations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
