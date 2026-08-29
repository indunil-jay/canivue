import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';

/// Horizontal dog-avatar switcher. The selected dog is always visually
/// obvious (ring + name label) and switching it re-scopes the rest of the
/// dashboard — brief §8 ("the selected dog should always be visually
/// obvious").
class ActiveDogSwitcher extends ConsumerWidget {
  const ActiveDogSwitcher({super.key, required this.dogs, required this.activeDog});

  final List<Pet> dogs;
  final Pet activeDog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dogs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final dog = dogs[index];
          final isActive = dog.id == activeDog.id;

          return GestureDetector(
            onTap: () => ref.read(activeDogIdProvider.notifier).state = dog.id,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? (isDark ? AppColors.primaryOnDark : AppColors.primary)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isActive ? 2.5 : 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: dog.assetImagePath != null
                        ? Image.asset(
                            dog.assetImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(child: Text(dog.avatarEmoji, style: const TextStyle(fontSize: 20))),
                          )
                        : ColoredBox(
                            color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
                            child: Center(child: Text(dog.avatarEmoji, style: const TextStyle(fontSize: 20))),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dog.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? (isDark ? AppColors.primaryOnDark : AppColors.primary)
                            : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
