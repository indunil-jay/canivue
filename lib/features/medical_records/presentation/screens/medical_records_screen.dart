import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/components/timeline_tile.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
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

/// Secure digital veterinary record (brief §20) — diagnoses, prescriptions,
/// lab results and notes on a chronological timeline, plus the ability to
/// upload a document or photo.
class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    if (!context.mounted) return;

    await ref.read(medicalRecordsControllerProvider(dogId).notifier).uploadDocument('Uploaded Document', file.path);

    if (context.mounted) {
      AppFeedback.showToast(context, title: 'Document uploaded', message: '${file.name} was added to $dogName\'s records.', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsControllerProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s Medical Records')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _upload(context, ref),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
      ),
      body: recordsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 64))),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load medical records.", onRetry: () => ref.invalidate(medicalRecordsControllerProvider(dogId))),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(icon: Icons.folder_open_rounded, title: 'No medical records yet', message: 'Upload a document or photo to start building this dog\'s medical history.');
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: [
              for (int i = 0; i < records.length; i++)
                TimelineTile(
                  icon: _iconFor(records[i].type),
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.primaryOnDark : AppColors.primary,
                  title: records[i].title,
                  subtitle: records[i].description,
                  dateLabel: DateFormat('MMM d, yyyy').format(records[i].date),
                  isFirst: i == 0,
                  isLast: i == records.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}
