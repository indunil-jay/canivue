import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/messages/presentation/controllers/messaging_controller.dart';
import 'package:canivue/features/messages/presentation/screens/chat_screen.dart';

/// Owner shell "Messages" tab — veterinary conversations (brief §19, §26).
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 72))),
        ),
        error: (_, _) => ErrorState(
          message: "We couldn't load your messages.",
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No messages yet',
              message: 'Conversations with your veterinarian will show up here once you book a consultation.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              return ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: Stack(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                      child: Center(child: Text(conversation.vetInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                    if (conversation.online)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.successOnDark : AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.darkBackground : AppColors.lightBackground, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(conversation.vetName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(conversation.lastMessagePreview, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat('h:mm a').format(conversation.lastMessageAt), style: theme.textTheme.labelSmall),
                    if (conversation.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: isDark ? AppColors.primaryOnDark : AppColors.primary, borderRadius: AppRadius.pillRadius),
                        child: Text('${conversation.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
