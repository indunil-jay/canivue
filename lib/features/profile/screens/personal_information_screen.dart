import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
    required this.userEmail,
    this.userName,
  });

  final String userEmail;
  final String? userName;

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Profile photo updated!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
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

                // Camera & Gallery options
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
                const SizedBox(height: 20),

                // Preset Emojis / Avatars
                Text(
                  'CHOOSE PRESET AVATAR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Personal details updated successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ChangePasswordModal(),
    );
  }

  Widget _buildAvatarWidget(ColorScheme colorScheme) {
    if (_imageFile != null) {
      return ClipOval(
        child: Image.file(
          _imageFile!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_selectedAvatarEmoji != null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          _selectedAvatarEmoji!,
          style: const TextStyle(fontSize: 48),
        ),
      );
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
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
          'Personal Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _handleSaveProfile,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save'),
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Avatar with Change Photo Button
                    Center(
                      child: Stack(
                        children: [
                          _buildAvatarWidget(colorScheme),
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
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Text(
                          'Change Profile Photo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section: Basic Details
                    Text(
                      'BASIC DETAILS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

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
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 18, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    CustomTextField(
                      controller: _addressController,
                      label: 'City / Location',
                      hintText: 'City, Country',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact
                    CustomTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Vet / Contact',
                      hintText: 'Phone & Contact Name',
                      prefixIcon: Icons.emergency_outlined,
                    ),
                    const SizedBox(height: 28),

                    // Section: Security & Password
                    Text(
                      'SECURITY & AUTHENTICATION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Change Password Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.lock_reset_rounded, color: colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Password',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Update your account password regularly to stay secure.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: _openChangePasswordModal,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Changes Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleSaveProfile,
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
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
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

class _ChangePasswordModal extends StatefulWidget {
  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  final _pwdFormKey = GlobalKey<FormState>();

  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdating = false;

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void _handleUpdatePassword() async {
    if (!_pwdFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isUpdating = false;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Password updated successfully!'),
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

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _pwdFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current password and create a new secure password.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Current Password
              CustomTextField(
                controller: _currentPwdController,
                label: 'Current Password',
                hintText: 'Enter current password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                controller: _newPwdController,
                label: 'New Password',
                hintText: 'Min. 8 characters',
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (val.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm New Password
              CustomTextField(
                controller: _confirmPwdController,
                label: 'Confirm New Password',
                hintText: 'Re-enter new password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (val != _newPwdController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isUpdating ? null : _handleUpdatePassword,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
