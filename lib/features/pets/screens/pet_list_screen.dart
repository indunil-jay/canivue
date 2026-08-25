import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/luxury_segmented_bar.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/add_edit_pet_screen.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/widgets/pet_card.dart';

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
      appBar: AppBar(
        title: Text(
          'My Pets (${_pets.length})',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: 'Add Pet',
            color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
            onPressed: _handleAddPet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.8) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search_rounded, color: isDark ? Colors.white60 : const Color(0xFF94A3B8)),
                        hintText: 'Search by pet name, breed...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Luxury Segmented Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LuxurySegmentedBar(
                    segments: _categories,
                    selectedIndex: _selectedCategoryIndex,
                    onChanged: (index) => setState(() => _selectedCategoryIndex = index),
                  ),
                ),
                const SizedBox(height: 14),

                // Pet List Feed
                Expanded(
                  child: _filteredPets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets_rounded, size: 54, color: isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
                              const SizedBox(height: 14),
                              Text(
                                'No pets found matching "$_searchQuery"',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          physics: const BouncingScrollPhysics(),
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
      ),
    );
  }
}
