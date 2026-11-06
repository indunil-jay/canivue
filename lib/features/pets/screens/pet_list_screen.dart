import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/add_edit_pet_screen.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/widgets/pet_card.dart';

/// Screen displaying the user's pets with quick search, category filters,
/// and instant transitions to health check scans and detailed telemetry.
class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final List<Pet> _pets = List.from(Pet.samplePets);
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final List<String> _categories = ['All Pets', 'Dogs', 'Cats', 'Senior Pets'];

  List<Pet> get _filteredPets {
    return _pets.where((pet) {
      final matchesSearch = pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedCategoryIndex == 1) {
        return pet.species.toLowerCase() == 'dog';
      } else if (_selectedCategoryIndex == 2) {
        return pet.species.toLowerCase() == 'cat';
      } else if (_selectedCategoryIndex == 3) {
        return pet.ageYears >= 5;
      }
      return true;
    }).toList();
  }

  void _handleAddPet() async {
    HapticFeedback.lightImpact();
    final newPet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(
        builder: (_) => const AddEditPetScreen(),
      ),
    );

    if (newPet != null) {
      setState(() {
        _pets.insert(0, newPet);
      });
    }
  }

  void _handlePetTap(Pet pet) async {
    HapticFeedback.lightImpact();
    final updatedPet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(pet: pet),
      ),
    );

    if (updatedPet != null) {
      final index = _pets.indexWhere((p) => p.id == updatedPet.id);
      if (index != -1) {
        setState(() {
          _pets[index] = updatedPet;
        });
      }
    }
  }

  void _navigateToScan(Pet pet) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(
          pets: _pets,
          initialPet: pet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : const Color(0xFF181A20),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0x4414B8A6) : const Color(0xFFBFE7DC),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🐾', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'MY FAMILY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'My Pets (${_pets.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Pet Pill Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleAddPet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Add Pet',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.search_rounded,
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        size: 20,
                      ),
                      hintText: 'Search by pet name, breed...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 3. Category Pills
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = _selectedCategoryIndex == index;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategoryIndex = index);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? (isDark ? Colors.white : const Color(0xFF181A20))
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? (isDark ? Colors.white : const Color(0xFF181A20))
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            _categories[index],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected
                                  ? (isDark ? const Color(0xFF181A20) : Colors.white)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // 4. Pet List
              Expanded(
                child: _filteredPets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              'No pets found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search or category filter.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        itemCount: _filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = _filteredPets[index];
                          return PetCard(
                            pet: pet,
                            onTap: () => _handlePetTap(pet),
                            onScanTap: () => _navigateToScan(pet),
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
}
