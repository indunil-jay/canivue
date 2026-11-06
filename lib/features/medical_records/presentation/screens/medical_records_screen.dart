import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/components/timeline_tile.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/medical_records/domain/medical_record.dart';
import 'package:canivue/features/medical_records/presentation/controllers/medical_records_controller.dart';

IconData _iconFor(MedicalRecordType type) => switch (type) {
      MedicalRecordType.diagnosis => Icons.assignment_rounded,
      MedicalRecordType.prescription => Icons.medication_rounded,
      MedicalRecordType.labResult => Icons.biotech_rounded,
      MedicalRecordType.note => Icons.sticky_note_2_rounded,
      MedicalRecordType.document => Icons.description_rounded,
    };

Color _colorFor(MedicalRecordType type, bool isDark) => switch (type) {
      MedicalRecordType.diagnosis => const Color(0xFFF59E0B),
      MedicalRecordType.prescription => const Color(0xFF10B981),
      MedicalRecordType.labResult => const Color(0xFF7A67EE),
      MedicalRecordType.note => const Color(0xFF0284C7),
      MedicalRecordType.document => isDark ? AppColors.primaryOnDark : AppColors.primary,
    };

/// Secure digital veterinary record vault: diagnoses, prescriptions,
/// lab results and notes on an encrypted timeline.
class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    if (!context.mounted) return;

    await ref.read(medicalRecordsControllerProvider(dogId).notifier).uploadDocument('Uploaded Document', file.path);

    if (context.mounted) {
      AppFeedback.showToast(
        context,
        title: 'Document Uploaded 📄',
        message: '${file.name} was added to $dogName\'s clinical records.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsControllerProvider(dogId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                                const Text('📋', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'CLINICAL VAULT',
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
                            '$dogName\'s Records',
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
                    // Upload Document Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _upload(context, ref),
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
                              const Icon(Icons.upload_file_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Upload',
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

              // 2. Records List
              Expanded(
                child: recordsAsync.when(
                  loading: () => ListView(
                    padding: const EdgeInsets.all(20),
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: SkeletonBox(height: 68, borderRadius: BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                  ),
                  error: (_, _) => ErrorState(
                    message: "We couldn't load medical records.",
                    onRetry: () => ref.invalidate(medicalRecordsControllerProvider(dogId)),
                  ),
                  data: (records) {
                    if (records.isEmpty) {
                      return EmptyState(
                        icon: Icons.folder_open_rounded,
                        title: 'No medical records yet',
                        message: 'Upload a prescription, lab result or clinic note to build $dogName\'s medical history.',
                        actionLabel: 'Upload Document',
                        onAction: () => _upload(context, ref),
                      );
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < records.length; i++)
                                TimelineTile(
                                  icon: _iconFor(records[i].type),
                                  color: _colorFor(records[i].type, isDark),
                                  title: records[i].title,
                                  subtitle: records[i].description,
                                  dateLabel: DateFormat('MMM d, yyyy').format(records[i].date),
                                  isFirst: i == 0,
                                  isLast: i == records.length - 1,
                                ),
                            ],
                          ),
                        ),
                      ],
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
