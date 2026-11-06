import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';

/// Screen allowing owners to add a new pet or edit an existing pet profile,
/// persisting changes directly into the [dogsProvider] repository.
class AddEditPetScreen extends ConsumerStatefulWidget {
  const AddEditPetScreen({
    super.key,
    this.pet,
  });

  final Pet? pet;

  @override
  ConsumerState<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends ConsumerState<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _yearsController;
  late final TextEditingController _monthsController;
  late final TextEditingController _weightController;
  late final TextEditingController _colorController;
  late final TextEditingController _microchipController;
  late final TextEditingController _vetController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _notesController;

  String _species = 'Dog';
  String _gender = 'Male';
  bool _isNeutered = true;
  String _bloodGroup = 'DEA 1.1+';

  File? _imageFile;
  String _selectedAvatarEmoji = '🐶';
  bool _isSaving = false;

  final List<String> _speciesList = ['Dog', 'Cat', 'Rabbit', 'Bird', 'Other'];
  final List<String> _bloodGroups = ['DEA 1.1+', 'DEA 1.1-', 'DEA 1.2+', 'Type A', 'Type B', 'Unknown'];
  final List<String> _presetPetEmojis = ['🐶', '🐕', '🐩', '🦮', '🐾', '🐱', '🐈', '🦊', '🦁', '🐻'];

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _nameController = TextEditingController(text: p?.name ?? '');
    _breedController = TextEditingController(text: p?.breed ?? '');
    _yearsController = TextEditingController(text: p != null ? '${p.ageYears}' : '2');
    _monthsController = TextEditingController(text: p != null ? '${p.ageMonths}' : '0');
    _weightController = TextEditingController(text: p != null ? '${p.weightKg}' : '15.0');
    _colorController = TextEditingController(text: p?.color ?? '');
    _microchipController = TextEditingController(text: p?.microchipId ?? '');
    _vetController = TextEditingController(text: p?.primaryVet ?? '');
    _allergiesController = TextEditingController(text: p != null ? p.allergies.join(', ') : '');
    _notesController = TextEditingController(text: p?.specialNotes ?? '');

    if (p != null) {
      _species = p.species;
      _gender = p.gender;
      _isNeutered = p.isNeutered;
      _bloodGroup = p.bloodGroup;
      _selectedAvatarEmoji = p.avatarEmoji;
      if (p.imagePath != null) {
        _imageFile = File(p.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    _vetController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pet Photo or Avatar',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED25E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFED25E).withValues(alpha: 0.4)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 28, color: Color(0xFFD97706)),
                              SizedBox(height: 8),
                              Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF4EC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_rounded, size: 28, color: Color(0xFF0D9488)),
                              SizedBox(height: 8),
                              Text('From Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'CHOOSE PET AVATAR',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetPetEmojis.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final emoji = _presetPetEmojis[index];
                      final isSelected = _selectedAvatarEmoji == emoji && _imageFile == null;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAvatarEmoji = emoji;
                            _imageFile = null;
                          });
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFED25E).withValues(alpha: 0.3)
                                : const Color(0xFFFAF7F2),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFED25E) : const Color(0xFFECE6DC),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                      });
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final allergiesList = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final savedPet = Pet(
      id: widget.pet?.id ?? 'pet-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      breed: _breedController.text.trim(),
      species: _species,
      ageYears: int.tryParse(_yearsController.text.trim()) ?? 0,
      ageMonths: int.tryParse(_monthsController.text.trim()) ?? 0,
      gender: _gender,
      weightKg: double.tryParse(_weightController.text.trim()) ?? 10.0,
      color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : 'Mixed',
      microchipId: _microchipController.text.trim().isNotEmpty ? _microchipController.text.trim() : '985141002348123',
      avatarEmoji: _selectedAvatarEmoji,
      imagePath: _imageFile?.path,
      assetImagePath: widget.pet?.assetImagePath,
      birthDate: widget.pet?.birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      isNeutered: _isNeutered,
      bloodGroup: _bloodGroup,
      allergies: allergiesList.isNotEmpty ? allergiesList : ['None reported'],
      primaryVet: _vetController.text.trim().isNotEmpty ? _vetController.text.trim() : 'Dr. Sarah Jenkins',
      specialNotes: _notesController.text.trim(),
    );

    // Save directly to the Riverpod repository so home, profile, and switcher instantly update
    if (widget.pet != null) {
      await ref.read(dogsProvider.notifier).updateDog(savedPet);
    } else {
      await ref.read(dogsProvider.notifier).addDog(savedPet);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    AppFeedback.showToast(
      context,
      title: widget.pet != null ? 'Profile Updated 🐾' : 'Pet Registered 🎉',
      message: '${savedPet.name}\'s profile has been successfully saved.',
      type: ToastType.success,
    );

    Navigator.of(context).pop(savedPet);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.pet != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit ${widget.pet!.name}' : 'Add New Pet',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF181A20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pet Avatar / Photo with warm offset backplate
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 96,
                              width: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFFFED25E), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFED25E).withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _imageFile != null && _imageFile!.existsSync()
                                  ? Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(_selectedAvatarEmoji, style: const TextStyle(fontSize: 48)),
                                      ),
                                    )
                                  : Center(
                                      child: Text(_selectedAvatarEmoji, style: const TextStyle(fontSize: 48)),
                                    ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: InkWell(
                                onTap: _showPhotoOptions,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF181A20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15,
                                    color: Color(0xFFFED25E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Text(
                            'Choose Photo or Avatar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Section: PET DETAILS
                      _buildSectionHeader('PET DETAILS', isDark),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B202C) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Pet Name
                            CustomTextField(
                              controller: _nameController,
                              label: 'Pet Name',
                              hintText: 'e.g. Buddy, Luna, Max',
                              prefixIcon: Icons.pets_rounded,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your pet name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Species Dropdown & Breed
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _species,
                                    decoration: InputDecoration(
                                      labelText: 'Species',
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF242A38) : const Color(0xFFFAF7F2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFECE6DC)),
                                      ),
                                    ),
                                    items: _speciesList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _species = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: CustomTextField(
                                    controller: _breedController,
                                    label: 'Breed',
                                    hintText: 'e.g. Golden Retriever',
                                    prefixIcon: Icons.category_outlined,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter pet breed';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Gender Selector
                            Row(
                              children: [
                                Text(
                                  'Gender:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : const Color(0xFF181A20),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                ChoiceChip(
                                  avatar: Icon(Icons.male_rounded, size: 18, color: _gender == 'Male' ? Colors.blue.shade700 : null),
                                  label: const Text('Male'),
                                  selected: _gender == 'Male',
                                  selectedColor: const Color(0xFFFED25E).withValues(alpha: 0.35),
                                  onSelected: (selected) {
                                    if (selected) setState(() => _gender = 'Male');
                                  },
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  avatar: Icon(Icons.female_rounded, size: 18, color: _gender == 'Female' ? Colors.pink.shade700 : null),
                                  label: const Text('Female'),
                                  selected: _gender == 'Female',
                                  selectedColor: const Color(0xFFFED25E).withValues(alpha: 0.35),
                                  onSelected: (selected) {
                                    if (selected) setState(() => _gender = 'Female');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Age (Years & Months) and Weight
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _yearsController,
                                    label: 'Years',
                                    hintText: '0',
                                    prefixIcon: Icons.cake_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _monthsController,
                                    label: 'Months',
                                    hintText: '0',
                                    prefixIcon: Icons.calendar_today_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _weightController,
                                    label: 'Weight (kg)',
                                    hintText: '0.0',
                                    prefixIcon: Icons.monitor_weight_outlined,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Coat Color
                            CustomTextField(
                              controller: _colorController,
                              label: 'Coat Color / Markings',
                              hintText: 'e.g. Golden Honey, Black & Tan',
                              prefixIcon: Icons.palette_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: HEALTH & IDENTIFICATION
                      _buildSectionHeader('HEALTH & IDENTIFICATION', isDark),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B202C) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Microchip ID
                            CustomTextField(
                              controller: _microchipController,
                              label: 'Microchip ID Number',
                              hintText: '15-digit microchip number',
                              prefixIcon: Icons.qr_code_2_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Neutered / Spayed switch – Material wrapper prevents
                            // "ListTile background may be invisible" assertion when
                            // SwitchListTile.tileColor is set inside a DecoratedBox container.
                            Material(
                              color: Colors.transparent,
                              child: SwitchListTile(
                              value: _isNeutered,
                              onChanged: (val) => setState(() => _isNeutered = val),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              tileColor: isDark ? const Color(0xFF242A38) : const Color(0xFFFAF7F2),
                              activeThumbColor: const Color(0xFF10B981),
                              title: Text(
                                'Neutered / Spayed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: isDark ? Colors.white : const Color(0xFF181A20),
                                ),
                              ),
                              subtitle: Text(
                                _isNeutered ? 'Yes, procedure completed' : 'No / Intact',
                                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                            ),
                            const SizedBox(height: 16),

                            // Blood Group
                            DropdownButtonFormField<String>(
                              initialValue: _bloodGroup,
                              decoration: InputDecoration(
                                labelText: 'Blood Group',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF242A38) : const Color(0xFFFAF7F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFECE6DC)),
                                ),
                              ),
                              items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _bloodGroup = val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Allergies
                            CustomTextField(
                              controller: _allergiesController,
                              label: 'Allergies & Sensitivities',
                              hintText: 'e.g. Chicken protein, Wheat (comma separated)',
                              prefixIcon: Icons.warning_amber_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Primary Vet Clinic
                            CustomTextField(
                              controller: _vetController,
                              label: 'Primary Vet Clinic & Doctor',
                              hintText: 'e.g. Dr. Sarah Jenkins (Oakwood Vet)',
                              prefixIcon: Icons.local_hospital_outlined,
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            CustomTextField(
                              controller: _notesController,
                              label: 'Special Care & Behavior Notes',
                              hintText: 'Daily routines, habits, medications, dietary needs...',
                              prefixIcon: Icons.notes_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20),
                            foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  isEditing ? 'Save Pet Profile' : 'Save Pet Profile',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 11.5,
        letterSpacing: 1.1,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      ),
    );
  }
}
