import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';
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
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Dogs', 'Cats', 'Senior Pets'];

  List<Pet> get _filteredPets {
    return _pets.where((pet) {
      final matchesSearch = pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedCategory == 'Dogs') {
        return pet.species.toLowerCase() == 'dog';
      } else if (_selectedCategory == 'Cats') {
        return pet.species.toLowerCase() == 'cat';
      } else if (_selectedCategory == 'Senior Pets') {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Pets (${_pets.length})',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Pet',
            onPressed: _handleAddPet,
          ),
          const SizedBox(width: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                        hintText: 'Search by pet name, breed...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Category filter chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Pet List
                Expanded(
                  child: _filteredPets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets_rounded, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No pets found matching "$_searchQuery"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _filteredPets.length,
                          itemBuilder: (context, index) {
                            final pet = _filteredPets[index];
                            return PetCard(
                              pet: pet,
                              onTap: () => _handlePetTap(pet),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _handleAddPet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Pet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
