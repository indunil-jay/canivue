import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/add_edit_pet_screen.dart';

/// Luxury Pet Switcher capsule row inspired by modern pet companion apps.
///
/// Features:
/// - Smooth active highlight with amber/teal glow
/// - Pet avatar thumbnail with high-res asset image
/// - Pet breed subtitle & status dot
/// - "Add Pet" quick button
/// - Apple-style press scaling (scale 0.96) and tactile haptics
class ActiveDogSwitcher extends ConsumerWidget {
  const ActiveDogSwitcher({
    super.key,
    required this.dogs,
    required this.activeDog,
  });

  final List<Pet> dogs;
  final Pet activeDog;

  void _onAddPet(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditPetScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dogs.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == dogs.length) {
            // "Add Pet" action pill
            return _AddPetButton(onTap: () => _onAddPet(context), isDark: isDark);
          }

          final dog = dogs[index];
          final isActive = dog.id == activeDog.id;

          return _DogCapsuleItem(
            dog: dog,
            isActive: isActive,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(activeDogIdProvider.notifier).state = dog.id;
            },
          );
        },
      ),
    );
  }
}

class _DogCapsuleItem extends StatefulWidget {
  const _DogCapsuleItem({
    required this.dog,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final Pet dog;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_DogCapsuleItem> createState() => _DogCapsuleItemState();
}

class _DogCapsuleItemState extends State<_DogCapsuleItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.isDark
        ? const Color(0xFF242A38)
        : Colors.white;

    final inactiveBg = widget.isDark
        ? const Color(0x1AFFFFFF)
        : const Color(0x0D181A20);

    final activeBorder = const Color(0xFFFED25E); // Warm Honey Gold from Pawsure
    final inactiveBorder = widget.isDark
        ? const Color(0x22FFFFFF)
        : const Color(0x1A181A20);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isActive ? activeBorder : inactiveBorder,
              width: widget.isActive ? 2.0 : 1.0,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: activeBorder.withValues(alpha: widget.isDark ? 0.25 : 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isActive ? activeBorder : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: widget.dog.assetImagePath != null
                          ? Image.asset(
                              widget.dog.assetImagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 22)),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF3FAF7),
                              child: Center(
                                child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                    ),
                  ),
                  if (widget.isActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.dog.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w600,
                      color: widget.isDark ? Colors.white : const Color(0xFF181A20),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.dog.breed,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  const _AddPetButton({required this.onTap, required this.isDark});

  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0x28FFFFFF) : const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF2A3444) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF181A20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Add Pet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
