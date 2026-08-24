import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

class AddEditPetScreen extends StatefulWidget {
  const AddEditPetScreen({
    super.key,
    this.pet,
  });

  final Pet? pet;

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 28, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 8),
                              const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.photo_library_rounded, size: 28, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 8),
                              const Text('From Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
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
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

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
      birthDate: widget.pet?.birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      isNeutered: _isNeutered,
      bloodGroup: _bloodGroup,
      allergies: allergiesList.isNotEmpty ? allergiesList : ['None reported'],
      primaryVet: _vetController.text.trim().isNotEmpty ? _vetController.text.trim() : 'Dr. Sarah Jenkins',
      specialNotes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(savedPet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(widget.pet != null ? 'Profile for ${savedPet.name} updated!' : '${savedPet.name} added to your pets!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit ${widget.pet!.name}' : 'Add New Pet',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pet Avatar with edit badge
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
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
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Text(
                                        _selectedAvatarEmoji,
                                        style: const TextStyle(fontSize: 48),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _selectedAvatarEmoji,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _showPhotoOptions,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section: Basic Info
                    Text(
                      'PET DETAILS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

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
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        Text('Gender:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 14),
                        ChoiceChip(
                          avatar: Icon(Icons.male_rounded, size: 18, color: _gender == 'Male' ? Colors.blue.shade700 : null),
                          label: const Text('Male'),
                          selected: _gender == 'Male',
                          onSelected: (selected) {
                            if (selected) setState(() => _gender = 'Male');
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          avatar: Icon(Icons.female_rounded, size: 18, color: _gender == 'Female' ? Colors.pink.shade700 : null),
                          label: const Text('Female'),
                          selected: _gender == 'Female',
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
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 28),

                    // Section: Health & Medical
                    Text(
                      'HEALTH & IDENTIFICATION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Microchip ID
                    CustomTextField(
                      controller: _microchipController,
                      label: 'Microchip ID Number',
                      hintText: '15-digit microchip number',
                      prefixIcon: Icons.qr_code_2_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Neutered / Spayed switch
                    SwitchListTile(
                      value: _isNeutered,
                      onChanged: (val) => setState(() => _isNeutered = val),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      title: const Text('Neutered / Spayed', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _isNeutered ? 'Yes, procedure completed' : 'No / Intact',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Blood Group
                    DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                isEditing ? 'Update Pet Profile' : 'Save Pet Profile',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
