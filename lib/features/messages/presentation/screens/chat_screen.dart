import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/message_bubble.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/messages/domain/conversation.dart';
import 'package:canivue/features/messages/domain/message.dart';
import 'package:canivue/features/messages/presentation/controllers/messaging_controller.dart';
import 'package:canivue/features/messages/presentation/widgets/consultation_summary_bubble.dart';

/// WhatsApp-inspired veterinary conversation (brief §19, §26): message
/// status, a typing indicator, online status, and consultation-context
/// records shared into the same thread.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: AppMotion.normal, curve: AppMotion.standard);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();

    final conversationId = widget.conversation.id;
    await ref.read(chatControllerProvider(conversationId).notifier).send(text);
    _scrollToBottom();

    ref.read(vetTypingProvider(conversationId).notifier).state = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) ref.read(vetTypingProvider(conversationId).notifier).state = false;
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final messagesAsync = ref.watch(chatControllerProvider(conversation.id));
    final isTyping = ref.watch(vetTypingProvider(conversation.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Center(child: Text(conversation.vetInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(conversation.vetName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    isTyping ? 'typing…' : (conversation.online ? 'Online' : 'Offline'),
                    style: theme.textTheme.labelSmall?.copyWith(color: isTyping || conversation.online ? (isDark ? AppColors.successOnDark : AppColors.success) : null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(20), child: SkeletonBox(height: 300)),
              error: (_, _) => ErrorState(message: "We couldn't load this conversation.", onRetry: () => ref.invalidate(chatControllerProvider(conversation.id))),
              data: (messages) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(top: 6), child: _TypingIndicator()));
                    }
                    final message = messages[index];
                    if (message.kind == MessageKind.consultationSummary) {
                      return const ConsultationSummaryBubble();
                    }
                    final isMine = message.sender == MessageSender.owner;
                    return MessageBubble(
                      text: message.text,
                      isMine: isMine,
                      timeLabel: DateFormat('h:mm a').format(message.timestamp),
                      statusIcon: isMine
                          ? (message.status == MessageStatus.read ? Icons.done_all_rounded : Icons.done_rounded)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.attach_file_rounded, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Message', border: InputBorder.none),
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: isDark ? AppColors.primaryOnDark : AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: SizedBox(
        width: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (i) => _Dot(delayMs: i * 150)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delayMs});
  final int delayMs;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = ((_controller.value * 1000 - widget.delayMs) % 1000) / 1000;
        final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0, 1);
        return Opacity(
          opacity: opacity.toDouble(),
          child: Container(height: 6, width: 6, decoration: BoxDecoration(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText, shape: BoxShape.circle)),
        );
      },
    );
  }
}
