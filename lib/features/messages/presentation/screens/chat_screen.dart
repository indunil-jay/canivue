import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/message_bubble.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/messages/domain/conversation.dart';
import 'package:canivue/features/messages/domain/message.dart';
import 'package:canivue/features/messages/presentation/controllers/messaging_controller.dart';
import 'package:canivue/features/messages/presentation/widgets/consultation_summary_bubble.dart';
import 'package:canivue/features/messages/presentation/widgets/live_telemetry_bubble.dart';
import 'package:canivue/features/messages/presentation/widgets/photo_attachment_bubble.dart';
import 'package:canivue/features/messages/presentation/widgets/telehealth_call_dialog.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';

/// WhatsApp/iMessage-level veterinary telehealth consultation conversation thread.
///
/// Designed with Apple-level fluid direct manipulation, spring transitions,
/// biometric telemetry sharing, live clinical summaries, and accessible tiered motion.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showActionTray = true;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        if (reduceMotion) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _controller.clear();

    final conversationId = widget.conversation.id;
    await ref.read(chatControllerProvider(conversationId).notifier).send(text);
    _scrollToBottom();

    ref.read(vetTypingProvider(conversationId).notifier).state = true;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) ref.read(vetTypingProvider(conversationId).notifier).state = false;
      _scrollToBottom();
    });
  }

  Future<void> _shareLiveTelemetry() async {
    HapticFeedback.mediumImpact();
    final dog = ref.read(activeDogProvider).value;
    final dogName = dog?.name ?? 'Buddy';

    final conversationId = widget.conversation.id;
    await ref.read(chatControllerProvider(conversationId).notifier).sendTelemetry(
          dogName: dogName,
          heartRate: 80,
          vitalityScore: 94,
          temperature: 38.4,
        );

    if (!mounted) return;
    AppFeedback.showToast(
      context,
      title: 'Collar Telemetry Sent 🐾',
      message: 'Live vitals shared with Dr. ${widget.conversation.vetName.split(' ').last}.',
      type: ToastType.success,
    );
    _scrollToBottom();

    ref.read(vetTypingProvider(conversationId).notifier).state = true;
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) ref.read(vetTypingProvider(conversationId).notifier).state = false;
      _scrollToBottom();
    });
  }

  Future<void> _sendPhotoAttachment() async {
    HapticFeedback.selectionClick();
    final conversationId = widget.conversation.id;

    await ref.read(chatControllerProvider(conversationId).notifier).sendPhoto(
          label: 'Ear & Paw Inspection (Day 3)',
        );

    if (!mounted) return;
    AppFeedback.showToast(
      context,
      title: 'Photo Uploaded 📷',
      message: 'Symptom photo shared with veterinary team.',
      type: ToastType.success,
    );
    _scrollToBottom();

    ref.read(vetTypingProvider(conversationId).notifier).state = true;
    Future.delayed(const Duration(milliseconds: 2200), () {
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
    final activeDog = ref.watch(activeDogProvider).value;
    final dogName = activeDog?.name ?? 'Buddy';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF181A20),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      conversation.vetInitials,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (conversation.online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
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
                  Text(
                    isTyping ? 'Dr. Sarah is typing…' : (conversation.online ? 'Online now · DVM Specialist' : 'Offline'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isTyping || conversation.online
                          ? const Color(0xFF10B981)
                          : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              TelehealthCallDialog.show(
                context,
                vetName: conversation.vetName,
                vetInitials: conversation.vetInitials,
                isVideo: false,
              );
            },
            icon: Icon(
              Icons.phone_outlined,
              color: isDark ? Colors.white70 : const Color(0xFF181A20),
              size: 20,
            ),
            tooltip: 'Voice Consultation',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              TelehealthCallDialog.show(
                context,
                vetName: conversation.vetName,
                vetInitials: conversation.vetInitials,
                isVideo: true,
              );
            },
            icon: const Icon(
              Icons.videocam_outlined,
              color: Color(0xFF0F766E),
              size: 22,
            ),
            tooltip: 'Live Video Consultation',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: Column(
          children: [
            // Active Collar Telemetry Status Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x1814B8A6) : AppColors.pastelMint,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0x3314B8A6) : const Color(0xFFBFE7DC),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const CanivuePawBoneLogo(size: 15, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TELEHEALTH ACTIVE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '· $dogName\'s Smart Collar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showActionTray = !_showActionTray);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showActionTray ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: const Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _showActionTray ? 'Hide Actions' : 'Tools',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message Stream
            Expanded(
              child: messagesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: SkeletonBox(height: 300, borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                error: (_, _) => ErrorState(
                  message: "We couldn't load this conversation.",
                  onRetry: () => ref.invalidate(chatControllerProvider(conversation.id)),
                ),
                data: (messages) {
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isTyping) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: _TypingIndicator(),
                        );
                      }

                      final message = messages[index];
                      final isMine = message.sender == MessageSender.owner;
                      final timeLabel = DateFormat('h:mm a').format(message.timestamp);

                      if (message.kind == MessageKind.consultationSummary) {
                        return ConsultationSummaryBubble(message: message);
                      }

                      if (message.kind == MessageKind.liveTelemetryShare) {
                        return LiveTelemetryBubble(
                          message: message,
                          isMine: isMine,
                          timeLabel: timeLabel,
                        );
                      }

                      if (message.kind == MessageKind.photoAttachment) {
                        return PhotoAttachmentBubble(
                          message: message,
                          isMine: isMine,
                          timeLabel: timeLabel,
                        );
                      }

                      return MessageBubble(
                        text: message.text,
                        isMine: isMine,
                        timeLabel: timeLabel,
                        statusIcon: isMine ? Icons.done_all_rounded : null,
                      );
                    },
                  );
                },
              ),
            ),

            // Quick Clinical Action Shelf (Animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _showActionTray
                  ? Container(
                      height: 42,
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        children: [
                          _actionChip(
                            icon: Icons.monitor_heart_rounded,
                            label: 'Share Vitals',
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                            onTap: _shareLiveTelemetry,
                          ),
                          const SizedBox(width: 8),
                          _actionChip(
                            icon: Icons.camera_alt_outlined,
                            label: 'Send Photo',
                            color: const Color(0xFF0284C7),
                            isDark: isDark,
                            onTap: _sendPhotoAttachment,
                          ),
                          const SizedBox(width: 8),
                          _actionChip(
                            icon: Icons.description_outlined,
                            label: 'Request Rx',
                            color: const Color(0xFF7A67EE),
                            isDark: isDark,
                            onTap: () {
                              _controller.text = 'Could you please issue an updated prescription summary for Buddy?';
                              _sendText();
                            },
                          ),
                          const SizedBox(width: 8),
                          _actionChip(
                            icon: Icons.medical_services_outlined,
                            label: 'Diet Switch',
                            color: const Color(0xFFD97706),
                            isDark: isDark,
                            onTap: () {
                              _controller.text = 'We are switching foods tomorrow. What proportion of transition do you recommend?';
                              _sendText();
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Message Composer (Apple iOS Message Style)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Plus / Attachment Trigger
                    IconButton(
                      onPressed: _sendPhotoAttachment,
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: isDark ? Colors.white70 : const Color(0xFF0F766E),
                        size: 24,
                      ),
                      tooltip: 'Attach Media or Telemetry',
                    ),
                    const SizedBox(width: 4),

                    // Text Input Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF15222D) : const Color(0xFFF7F5F0),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Message Dr. ${conversation.vetName.split(' ').last}...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendText(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Send Button with Haptic Response
                    GestureDetector(
                      onTap: _sendText,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
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

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🩺', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) => _Dot(delayMs: i * 150)),
            ),
          ),
        ],
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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = ((_controller.value * 1000 - widget.delayMs) % 1000) / 1000;
        final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0, 1);
        return Opacity(
          opacity: opacity.toDouble(),
          child: Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
