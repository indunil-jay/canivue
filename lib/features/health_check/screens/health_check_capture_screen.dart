import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/utils/page_transitions.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/health_check/screens/health_check_result_screen.dart';
import 'package:canivue/features/health_check/services/fusion_risk_engine.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// Owner-facing entry point for a single AI Health Check run. Collects the
/// three evidence streams described in the proposal — a photo, smart-collar
/// status, and a free-text symptom description — then runs them through the
/// [FusionRiskEngine] and hands the result to [HealthCheckResultScreen].
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
        setState(() => _imageFile = File(pickedFile.path));
        if (mounted) {
          AppFeedback.showToast(
            context,
            title: 'Photo Uploaded 📸',
            message: 'Image ready for high-resolution canine lesion/symptom analysis.',
            type: ToastType.success,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      AppFeedback.showToast(
        context,
        title: 'Camera Error',
        message: 'Could not access image: $e',
        type: ToastType.error,
      );
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
                      'Add Symptom Photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
    AppFeedback.showLuxuryBottomSheet(
      context,
      title: 'Add Symptom Photo',
      headerIcon: Icons.camera_alt_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PhotoOptionTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PhotoOptionTile(
                        icon: Icons.camera_alt_rounded,
                        label: 'Take Photo',
                        onTap: () {
                          Navigator.of(context).pop();
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
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoOptionTile(
                  icon: Icons.photo_library_rounded,
                  label: 'From Gallery',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _imageFile = null);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 8),
              ],
              ),
            ],
          ),
          if (_imageFile != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() => _imageFile = null);
                Navigator.of(context).pop();
                AppFeedback.showToast(
                  context,
                  message: 'Photo removed',
                  type: ToastType.info,
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
              label: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _toggleCollar(bool value) async {
    if (!value) {
      setState(() => _collarConnected = false);
      AppFeedback.showToast(
        context,
        message: 'Smart Collar disconnected',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _collarConnecting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _collarConnecting = false;
      _collarConnected = true;
    });
    AppFeedback.showToast(
      context,
      title: 'Smart Collar Linked ⚡',
      message: 'Streaming real-time heart rate (82 BPM) & activity telemetry.',
      type: ToastType.success,
    );
  }

  Future<void> _runAnalysis() async {
    final pet = _selectedPet;
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a pet to run the health check.'), behavior: SnackBarBehavior.floating),
      AppFeedback.showToast(
        context,
        title: 'Pet Selection Required',
        message: 'Please select a pet to run the health check.',
        type: ToastType.warning,
      );
      return;
    }
    if (_imageFile == null && !_collarConnected && _symptomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least a photo, collar data, or a symptom description.'),
          behavior: SnackBarBehavior.floating,
        ),
      AppFeedback.showToast(
        context,
        title: 'Evidence Needed',
        message: 'Please provide at least a photo, collar telemetry, or symptom notes.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    // Simulated on-device fusion latency, keeping within the proposal's
    // "current multimodal inference <= 3 seconds" performance target.
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Health Check',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isAnalyzing,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Intro banner
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Combine a photo, your smart collar and a symptom note. Our confidence-weighted adaptive fusion engine analyses them together.',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 12.5, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0),
                        const SizedBox(height: 22),

                        if (!widget.lockPetSelection && widget.pets.length > 1) ...[
                          _SectionLabel(text: 'SELECT PET'),
                          const _SectionLabel(text: 'SELECT PET'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 84,
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.pets.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final pet = widget.pets[index];
                                final selected = pet.id == _selectedPet?.id;
                                return _PetChip(
                                  pet: pet,
                                  selected: selected,
                                  onTap: () => setState(() => _selectedPet = pet),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        _SectionLabel(text: '1 · PHOTO EVIDENCE (OPTIONAL)'),
                        const _SectionLabel(text: '1 · PHOTO EVIDENCE (OPTIONAL)'),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _showPhotoOptions,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                                style: BorderStyle.solid,
                                color: _imageFile != null ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.6),
                                width: _imageFile != null ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _imageFile != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(_imageFile!, fit: BoxFit.cover),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.black.withValues(alpha: 0.55),
                                          child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                        right: 12,
                                        bottom: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                              SizedBox(width: 4),
                                              Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 30),
                                      Icon(Icons.add_a_photo_outlined, size: 36, color: colorScheme.primary),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add a photo of the affected area',
                                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
                                        'Upload or take a photo of symptoms',
                                        style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'e.g. skin, eye, mouth, posture, gait',
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _SectionLabel(text: '2 · SMART COLLAR (OPTIONAL)'),
                        const _SectionLabel(text: '2 · SMART COLLAR (OPTIONAL)'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                            border: Border.all(
                              color: _collarConnected ? const Color(0xFF16A34A) : colorScheme.outlineVariant.withValues(alpha: 0.6),
                              width: _collarConnected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_collarConnected ? const Color(0xFF16A34A) : Colors.black).withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (_collarConnected ? AppTheme.successGreen : colorScheme.primary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.sensors_rounded,
                                  color: _collarConnected ? AppTheme.successGreen : colorScheme.primary,
                                  size: 22,
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
                                          : (_collarConnected ? 'Connected · Motion data synced' : 'ESP32 + MPU6050 Smart Collar'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (_collarConnected ? const Color(0xFF16A34A) : colorScheme.primary).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _collarConnected
                                          ? 'Scratching, activity and gait signals included'
                                          : 'Adds behavioural motion data to the analysis',
                                      style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                                    child: Icon(
                                      _collarConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_rounded,
                                      color: _collarConnected ? const Color(0xFF16A34A) : colorScheme.primary,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                              _collarConnecting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.4),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Canivue SmartCollar v2',
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          _collarConnected
                                              ? 'Active sync • Heart rate 82 BPM, Activity normal'
                                              : 'Pair collar for real-time biometric fusion',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: _collarConnected ? const Color(0xFF16A34A) : colorScheme.onSurfaceVariant,
                                            fontWeight: _collarConnected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_collarConnecting)
                                    const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  : Switch(
                                  else
                                    Switch(
                                      value: _collarConnected,
                                      onChanged: _toggleCollar,
                                      activeThumbColor: AppTheme.successGreen,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _SectionLabel(text: '3 · DESCRIBE WHAT YOU\'RE SEEING'),
                        const _SectionLabel(text: '3 · SYMPTOM DESCRIPTION'),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'Observed Signs & Behaviors',
                          hintText: 'e.g. Scratching right ear repeatedly for 2 days, lethargic after morning walk, reduced appetite.',
                          prefixIcon: Icons.notes_rounded,
                          controller: _symptomController,
                          label: '',
                          hintText: 'e.g. "Scratching a lot for 3 days, redness behind the ears, seems worse today"',
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                          isGlass: false,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The more detail you give, the more the text stream can contribute to the fused result.',
                          style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),

                        // Run analysis button
                        // Run AI Health Check button
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isAnalyzing ? null : _runAnalysis,
                            onPressed: _runAnalysis,
                            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            label: const Text(
                              'Run AI Analysis',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                            label: const Text(
                              'Run AI Analysis',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'A preliminary decision-support result, not a substitute for veterinary examination.',
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_isAnalyzing) const _AnalyzingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            Icon(icon, size: 28, color: AppTheme.cyanAccent),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _PetChip extends StatelessWidget {
  const _PetChip({required this.pet, required this.selected, required this.onTap});
  final Pet pet;
  final bool selected;
  final VoidCallback onTap;

  Widget _buildAvatar() {
    if (pet.imagePath != null && File(pet.imagePath!).existsSync()) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(File(pet.imagePath!)),
      );
    }
    if (pet.assetImagePath != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(pet.assetImagePath!),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: Text(pet.avatarEmoji, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.6) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: selected ? 1.6 : 1,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: pet.imagePath != null && File(pet.imagePath!).existsSync() ? FileImage(File(pet.imagePath!)) : null,
              child: pet.imagePath == null ? Text(pet.avatarEmoji, style: const TextStyle(fontSize: 18)) : null,
            ),
            _buildAvatar(),
            const SizedBox(height: 6),
            Text(
              pet.name,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? colorScheme.primary : null),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? colorScheme.primary : null,
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
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A2540).withValues(alpha: 0.95),
                        const Color(0xFF061126).withValues(alpha: 0.98),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyanAccent.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _PulsingIcon(icon: Icons.photo_camera_rounded, delay: 0),
                          const SizedBox(width: 14),
                          const _PulsingIcon(icon: Icons.sensors_rounded, delay: 150),
                          const SizedBox(width: 14),
                          const _PulsingIcon(icon: Icons.notes_rounded, delay: 300),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Fusing multimodal evidence…',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Weighting image, collar & text by confidence and clinical severity',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fusing multimodal evidence…',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Weighting image, collar & text by confidence and quality',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
              ),
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
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
      child: Icon(icon, color: Colors.white, size: 22),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 500.ms, delay: delay.ms)
        .then()
        .scaleXY(end: 1.15, duration: 400.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(end: 1 / 1.15, duration: 400.ms, curve: Curves.easeInOut);
  }
}
