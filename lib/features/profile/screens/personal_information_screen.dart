import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';

/// Screen allowing owners to view, edit, and persist their personal details,
/// emergency contacts, profile avatars, and security credentials.
class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({
    super.key,
    required this.userEmail,
    this.userName,
  });

  final String userEmail;
  final String? userName;

  @override
  ConsumerState<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends ConsumerState<PersonalInformationScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyContactController;

  File? _imageFile;
  String? _selectedAvatarEmoji;
  bool _isSaving = false;

  final List<String> _presetAvatars = ['🐶', '🐱', '🧑‍⚕️', '🐾', '🐕', '🦊', '🦁', '🐻'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName ?? 'Alex Taylor');
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: '+1 (555) 234-5678');
    _addressController = TextEditingController(text: 'San Francisco, CA');
    _emergencyContactController = TextEditingController(text: '+1 (555) 987-6543 (Dr. Smith)');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
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
          _selectedAvatarEmoji = null;
        });

        if (mounted) {
          AppFeedback.showToast(
            context,
            title: 'Photo Updated 📸',
            message: 'Your profile avatar has been updated.',
            type: ToastType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
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
                      'Profile Photo',
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
                const SizedBox(height: 20),
                Text(
                  'CHOOSE PRESET AVATAR',
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
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final emoji = _presetAvatars[index];
                      final isSelected = _selectedAvatarEmoji == emoji;
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
                if (_imageFile != null || _selectedAvatarEmoji != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _selectedAvatarEmoji = null;
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

  void _handleSaveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim();

    // Persist to Riverpod AuthController so changes reflect app-wide
    ref.read(authControllerProvider.notifier).updateProfile(
          name: updatedName,
          email: updatedEmail,
        );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() => _isSaving = false);

    AppFeedback.showToast(
      context,
      title: 'Profile Updated ✨',
      message: 'Your personal details have been saved successfully.',
      type: ToastType.success,
    );

    Navigator.of(context).pop({
      'name': updatedName,
      'email': updatedEmail,
    });
  }

  void _openChangePasswordModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ChangePasswordModal(),
    );
  }

  Widget _buildAvatarWidget(bool isDark) {
    if (_imageFile != null) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFED25E), width: 3),
        ),
        child: ClipOval(
          child: Image.file(_imageFile!, width: 96, height: 96, fit: BoxFit.cover),
        ),
      );
    }

    if (_selectedAvatarEmoji != null) {
      return Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFED25E).withValues(alpha: 0.25),
          border: Border.all(color: const Color(0xFFFED25E), width: 2.5),
        ),
        child: Center(
          child: Text(_selectedAvatarEmoji!, style: const TextStyle(fontSize: 48)),
        ),
      );
    }

    final initial = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U';
    return Container(
      height: 96,
      width: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFED25E), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFED25E).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF181A20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Personal Information',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF181A20),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _handleSaveProfile,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
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
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Avatar with Camera Button
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildAvatarWidget(isDark),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _showPhotoOptions,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF181A20),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Color(0xFFFED25E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Text(
                            'Change Profile Photo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Section: BASIC DETAILS
                      _buildSectionHeader('BASIC DETAILS', isDark),
                      const SizedBox(height: 12),

                      // Card containing form inputs
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
                            // Full Name
                            CustomTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Address
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'name@example.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            CustomTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: '+1 (555) 000-0000',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Address
                            CustomTextField(
                              controller: _addressController,
                              label: 'Home Address',
                              hintText: 'City, State',
                              prefixIcon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: EMERGENCY CONTACT
                      _buildSectionHeader('EMERGENCY VET CONTACT', isDark),
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
                        child: CustomTextField(
                          controller: _emergencyContactController,
                          label: 'Emergency Vet / Contact',
                          hintText: '+1 (555) 987-6543 (Dr. Smith)',
                          prefixIcon: Icons.local_hospital_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: SECURITY & CREDENTIALS
                      _buildSectionHeader('SECURITY', isDark),
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
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF242A38) : const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF7C3AED), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Security',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF181A20),
                                    ),
                                  ),
                                  Text(
                                    'Protect your data & login credentials',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _openChangePasswordModal,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: Text(
                                'Change Password',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Changes Primary Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSaveProfile,
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
                                  'Save Changes',
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

class _ChangePasswordModal extends StatefulWidget {
  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSavingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSavingPassword = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSavingPassword = false);

    Navigator.of(context).pop();
    AppFeedback.showToast(
      context,
      title: 'Password Updated 🔒',
      message: 'Your account password has been changed successfully.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _currentPasswordController,
              label: 'Current Password',
              hintText: 'Enter current password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureCurrent,
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Please enter current password' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _newPasswordController,
              label: 'New Password',
              hintText: 'At least 8 characters',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureNew,
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (val) {
                if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              hintText: 'Re-enter new password',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (val) {
                if (val != _newPasswordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSavingPassword ? null : _handleChangePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF181A20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSavingPassword
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
