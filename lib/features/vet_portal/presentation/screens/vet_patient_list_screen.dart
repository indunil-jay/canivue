import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_patient_detail_screen.dart';

/// Veterinarian's patient list (brief §33-34) with a quick way to spot who
/// needs attention.
class VetPatientListScreen extends ConsumerStatefulWidget {
  const VetPatientListScreen({super.key});

  @override
  ConsumerState<VetPatientListScreen> createState() => _VetPatientListScreenState();
}

class _VetPatientListScreenState extends ConsumerState<VetPatientListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(vetPatientsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: AppRadius.xlRadius,
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(hintText: 'Search patients or owners', border: InputBorder.none, isDense: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              loading: () => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 76))),
              ),
              error: (_, _) => ErrorState(message: "We couldn't load patients.", onRetry: () => ref.invalidate(vetPatientsProvider)),
              data: (patients) {
                final filtered = patients.where((p) => p.dogName.toLowerCase().contains(_query.toLowerCase()) || p.ownerName.toLowerCase().contains(_query.toLowerCase())).toList();
                if (filtered.isEmpty) {
                  return const EmptyState(icon: Icons.pets_outlined, title: 'No patients found', message: 'Try a different search term.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _PatientTile(patient: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});

  final VetPatient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VetPatientDetailScreen(patient: patient))),
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: patient.hasCriticalAlert ? (isDark ? AppColors.errorOnDark : AppColors.error).withValues(alpha: 0.5) : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${patient.dogName} · ${patient.breed}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Owner: ${patient.ownerName} · Last visit ${DateFormat('MMM d').format(patient.lastVisit)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
            if (patient.hasCriticalAlert)
              Icon(Icons.warning_rounded, color: isDark ? AppColors.errorOnDark : AppColors.error, size: 20)
            else if (patient.needsFollowUp)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: isDark ? 0.18 : 0.1), borderRadius: AppRadius.pillRadius),
                child: Text('Follow-up', style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.warningOnDark : AppColors.warning, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
