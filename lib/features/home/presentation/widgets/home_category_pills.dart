import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/devices/presentation/screens/device_management_screen.dart';
import 'package:canivue/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:canivue/features/vets/presentation/screens/vet_discovery_screen.dart';
import 'package:canivue/features/preventive_care/presentation/screens/preventive_care_screen.dart';

/// Category quick-navigation pills inspired by Image 3 (PawMate).
///
/// Features:
/// - Rounded pastel squares with custom iconography
/// - Tactile micro-bounce on press (scale 0.94)
/// - Direct navigation to core pet services
class HomeCategoryPills extends StatelessWidget {
  const HomeCategoryPills({
    super.key,
    required this.dog,
    required this.dogs,
  });

  final Pet dog;
  final List<Pet> dogs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      _CategoryItem(
        label: 'AI Scanner',
        icon: Icons.auto_awesome_rounded,
        bgColor: const Color(0xFFDDF4EC),
        iconColor: const Color(0xFF0D9488),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: dog),
          ),
        ),
      ),
      _CategoryItem(
        label: 'Vaccine Log',
        icon: Icons.vaccines_rounded,
        bgColor: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF7C3AED),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PreventiveCareScreen(dogId: dog.id, dogName: dog.name),
          ),
        ),
      ),
      _CategoryItem(
        label: 'My Pets',
        icon: Icons.pets_rounded,
        bgColor: const Color(0xFFFFF3D6),
        iconColor: const Color(0xFFD97706),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetListScreen()),
        ),
      ),
      _CategoryItem(
        label: 'Telemetry',
        icon: Icons.bluetooth_connected_rounded,
        bgColor: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeviceManagementScreen(dogId: dog.id, dogName: dog.name),
          ),
        ),
      ),
      _CategoryItem(
        label: 'Nutrition',
        icon: Icons.restaurant_rounded,
        bgColor: const Color(0xFFFFEDD5),
        iconColor: const Color(0xFFEA580C),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NutritionScreen(dogId: dog.id, dogName: dog.name),
          ),
        ),
      ),
      _CategoryItem(
        label: 'Find Vet',
        icon: Icons.medical_services_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VetDiscoveryScreen(dogId: dog.id, dogName: dog.name),
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _CategoryButton(item: item, isDark: isDark);
        },
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
}

class _CategoryButton extends StatefulWidget {
  const _CategoryButton({required this.item, required this.isDark});

  final _CategoryItem item;
  final bool isDark;

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.isDark
        ? const Color(0xFF242A38)
        : widget.item.bgColor;

    final effectiveIconColor = widget.isDark
        ? Colors.white
        : widget.item.iconColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.item.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isDark ? const Color(0x22FFFFFF) : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveBg.withValues(alpha: widget.isDark ? 0.2 : 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.item.icon,
                color: effectiveIconColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.item.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
