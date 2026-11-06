import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/utils/page_transitions.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/health_check/screens/health_check_result_screen.dart';
import 'package:canivue/features/health_check/services/fusion_risk_engine.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// Owner-facing entry point for an AI Health Check run:
/// combines photo evidence, smart collar telemetry, and symptom observations.
class HealthCheckCaptureScreen extends StatefulWidget {
  const HealthCheckCaptureScreen({
    super.key,
    required this.pets,
    this.initialPet,
    this.lockPetSelection = false,
  });

  final List<Pet> pets;
  final Pet? initialPet;
  final bool lockPetSelection;

  @override
  State<HealthCheckCaptureScreen> createState() => _HealthCheckCaptureScreenState();
}

class _HealthCheckCaptureScreenState extends State<HealthCheckCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _symptomController = TextEditingController();

  Pet? _selectedPet;
  File? _imageFile;
  bool _collarConnected = false;
  bool _collarConnecting = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selectedPet = widget.initialPet ?? (widget.pets.isNotEmpty ? widget.pets.first : null);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
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
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 36,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Symptom Photo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _PhotoOptionTile(
                        icon: Icons.camera_alt_rounded,
                        label: 'Take Photo',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PhotoOptionTile(
                        icon: Icons.photo_library_rounded,
                        label: 'From Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _imageFile = null);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 18),
                    label: Text(
                      'Remove photo',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFF43F5E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleCollar(bool value) async {
    HapticFeedback.lightImpact();
    if (!value) {
      setState(() => _collarConnected = false);
      return;
    }
    setState(() => _collarConnecting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _collarConnecting = false;
      _collarConnected = true;
    });
  }

  void _loadSampleCase({
    required String symptoms,
    bool collar = true,
  }) {
    HapticFeedback.lightImpact();
    setState(() {
      _symptomController.text = symptoms;
      _collarConnected = collar;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loaded sample observation & paired smart collar data! Tap "Run AI Analysis" below.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _applySymptom(String symptom) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_symptomController.text.trim().isEmpty) {
        _symptomController.text = symptom;
      } else {
        _symptomController.text = '${_symptomController.text.trim()}, $symptom';
      }
    });
  }

  Future<void> _runAnalysis() async {
    final pet = _selectedPet;
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a pet to run the health check.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_imageFile == null && !_collarConnected && _symptomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least a photo, collar data, or a symptom description.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final result = FusionRiskEngine.run(
      pet: pet,
      hasImage: _imageFile != null,
      hasWearable: _collarConnected,
      symptomText: _symptomController.text,
    );

    setState(() => _isAnalyzing = false);
    Navigator.of(context).push(fadeSlidePageRoute(HealthCheckResultScreen(result: result)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        title: Text(
          'AI Health Check',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: AbsorbPointer(
          absorbing: _isAnalyzing,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Intro banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Combine a photo, smart collar vitals and your observation note. Our multi-modal neural fusion engine evaluates disease trajectories.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 14),

                    // Quick Demo / Sample Pre-fill Card
                    _buildSampleDemoCard(isDark),
                    const SizedBox(height: 20),

                    if (!widget.lockPetSelection && widget.pets.isNotEmpty) ...[
                      _sectionHeader('SELECT PET FOR DIAGNOSTICS', isDark),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.pets.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final pet = widget.pets[index];
                            final selected = pet.id == _selectedPet?.id;
                            return _PetChip(
                              pet: pet,
                              selected: selected,
                              onTap: () => setState(() => _selectedPet = pet),
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _sectionHeader('1 · PHOTO EVIDENCE (OPTIONAL)', isDark),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _showPhotoOptions,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        height: 155,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageFile != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_imageFile!, fit: BoxFit.cover),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                                      child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF0F766E), size: 26),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Add a photo of the affected area',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Skin, eyes, gait, or oral symptoms',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionHeader('2 · SMART COLLAR (OPTIONAL)', isDark),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_collarConnected ? const Color(0xFF10B981) : const Color(0xFF0F766E))
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.sensors_rounded,
                              color: _collarConnected ? const Color(0xFF10B981) : const Color(0xFF0F766E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _collarConnecting
                                      ? 'Pairing with collar…'
                                      : (_collarConnected ? 'Connected · Real-time Synced' : 'Canivue Smart Collar'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _collarConnected
                                      ? 'Scratching, resting heart rate & gait active'
                                      : 'Fuses motion telemetry with visual symptoms',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _collarConnecting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                )
                              : Switch(
                                  value: _collarConnected,
                                  onChanged: _toggleCollar,
                                  activeColor: const Color(0xFF10B981),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionHeader('3 · DESCRIBE OBSERVATIONS', isDark),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _symptomController,
                      label: '',
                      hintText: 'e.g. "Frequent scratching around left ear for 3 days, mild redness, lethargic after walks"',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickSymptomChip(
                          label: '🐾 Limping / Stiffness',
                          onTap: () => _applySymptom('Mild limping on left rear leg after exercise, stiff when standing up.'),
                          isDark: isDark,
                        ),
                        _QuickSymptomChip(
                          label: '🩺 Scratching & Redness',
                          onTap: () => _applySymptom('Frequent scratching around ears and neck for 3 days with mild redness.'),
                          isDark: isDark,
                        ),
                        _QuickSymptomChip(
                          label: '😮‍💨 Persistent Cough',
                          onTap: () => _applySymptom('Dry hacking cough especially after running, slight wheezing at rest.'),
                          isDark: isDark,
                        ),
                        _QuickSymptomChip(
                          label: '🥣 Low Appetite',
                          onTap: () => _applySymptom('Refusing dry kibble for 2 days, lethargic, drinking normal water.'),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Run Analysis Button
                    FilledButton(
                      onPressed: _isAnalyzing ? null : _runAnalysis,
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFF00F2FE)),
                          const SizedBox(width: 8),
                          Text(
                            'Run AI Analysis',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isAnalyzing) const _AnalyzingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleDemoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0x33FED25E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFED25E).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Demo / Test Run',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Pre-fill sample symptoms & collar telemetry',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _loadSampleCase(
              symptoms: 'Scratching a lot for 3 days, redness behind the ears, seems worse today',
              collar: true,
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: const Color(0xFFFED25E),
              foregroundColor: const Color(0xFF181A20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Fill Demo',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 11.5,
        letterSpacing: 0.6,
        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
      ),
    );
  }
}

class _QuickSymptomChip extends StatelessWidget {
  const _QuickSymptomChip({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF0F766E)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF181A20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetChip extends StatelessWidget {
  const _PetChip({
    required this.pet,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final Pet pet;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF152D28) : AppColors.pastelMint)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF10B981)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: pet.imagePath != null && File(pet.imagePath!).existsSync()
                  ? FileImage(File(pet.imagePath!))
                  : (pet.assetImagePath != null ? AssetImage(pet.assetImagePath!) as ImageProvider : null),
              child: (pet.imagePath == null && pet.assetImagePath == null)
                  ? Text(pet.avatarEmoji, style: const TextStyle(fontSize: 20))
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              pet.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E))
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 36),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PulsingIcon(icon: Icons.photo_camera_rounded, delay: 0),
                    const SizedBox(width: 14),
                    _PulsingIcon(icon: Icons.sensors_rounded, delay: 150),
                    const SizedBox(width: 14),
                    _PulsingIcon(icon: Icons.notes_rounded, delay: 300),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Fusing Multi-Modal Evidence…',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF181A20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Synthesizing computer vision, smart collar accelerometer telemetry, and clinical symptom tokens.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
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

class _PulsingIcon extends StatelessWidget {
  const _PulsingIcon({required this.icon, required this.delay});
  final IconData icon;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 500.ms, delay: delay.ms)
        .then()
        .scaleXY(end: 1.15, duration: 400.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(end: 1 / 1.15, duration: 400.ms, curve: Curves.easeInOut);
  }
}
