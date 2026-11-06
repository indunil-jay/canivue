import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key, this.initialTopic});

  final String? initialTopic;

  static Future<void> show(BuildContext context, {String? initialTopic}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => CreatePostSheet(initialTopic: initialTopic),
    );
  }

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  late String _selectedTopic;

  static const List<String> _topics = [
    'Skin Allergies',
    'Arthritis',
    'Obesity',
    'Digestive Problems',
    'General Care',
    'Nutrition',
    'Behavior & Training',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.initialTopic ?? _topics.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      AppFeedback.showToast(
        context,
        title: 'Empty Post',
        message: 'Please write something before publishing.',
        type: ToastType.info,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final user = ref.read(authControllerProvider);
    final activeDog = ref.read(activeDogProvider).value;

    final authorName = user?.name.isNotEmpty == true
        ? user!.name
        : (activeDog != null ? '${activeDog.name}\'s Family' : 'Liam Parker');

    final isVet = user?.role == UserRole.veterinarian;

    final initials = authorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    try {
      await ref.read(communityFeedControllerProvider.notifier).createPost(
            content: text,
            communityTag: _selectedTopic,
            authorName: authorName,
            authorInitials: initials.isEmpty ? 'LP' : initials,
            isVeterinarian: isVet,
          );

      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showToast(
          context,
          title: 'Published! 🎉',
          message: 'Your post is now live in the $_selectedTopic community.',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppFeedback.showToast(
          context,
          title: 'Failed to Post',
          message: e.toString(),
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = ref.read(authControllerProvider);
    final activeDog = ref.read(activeDogProvider).value;

    final authorName = user?.name.isNotEmpty == true
        ? user!.name
        : (activeDog != null ? '${activeDog.name}\'s Family' : 'Liam Parker');
    final isVet = user?.role == UserRole.veterinarian;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1720) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        bottomInset > 0 ? bottomInset + 16 : MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
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

          // Header
          Row(
            children: [
              Text(
                'Create Community Post',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Author pill
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: isVet
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        authorName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (isVet) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                      ],
                    ],
                  ),
                  Text(
                    isVet ? '🩺 Licensed Veterinarian' : '🐾 Dog Owner',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (activeDog != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '🐕 ${activeDog.name}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Topic Chips Selector
          Text(
            'SELECT COMMUNITY TOPIC',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _topics.map((topic) {
                final isSelected = _selectedTopic == topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      topic,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                    backgroundColor: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTopic = topic);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Post Content Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: _contentController,
              focusNode: _focusNode,
              maxLines: 5,
              minLines: 3,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.45,
              ),
              decoration: InputDecoration(
                hintText: 'Share diet transitions, ask vet advice, or post recovery milestones for your dog...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Action Row
          Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  AppFeedback.showToast(
                    context,
                    title: 'Attach Photo',
                    message: 'Photo attachment simulated for demo.',
                    type: ToastType.info,
                  );
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                color: const Color(0xFF0F766E),
                tooltip: 'Attach Photo',
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final current = _contentController.text;
                  _contentController.text = current.isEmpty ? '#Question ' : '$current #Question ';
                  _contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _contentController.text.length),
                  );
                },
                icon: const Icon(Icons.tag_rounded),
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                tooltip: 'Add Tag',
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  _isSubmitting ? 'Posting...' : 'Publish',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
