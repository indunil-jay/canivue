import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/preventive_care/domain/care_task.dart';
import 'package:canivue/features/preventive_care/presentation/controllers/care_task_controller.dart';

IconData _iconFor(CareTaskCategory category) => switch (category) {
      CareTaskCategory.vaccination => Icons.vaccines_rounded,
      CareTaskCategory.deworming => Icons.bug_report_rounded,
      CareTaskCategory.fleaTick => Icons.pest_control_rounded,
      CareTaskCategory.dental => Icons.medical_information_rounded,
      CareTaskCategory.grooming => Icons.content_cut_rounded,
      CareTaskCategory.annualCheck => Icons.event_available_rounded,
      CareTaskCategory.weightGoal => Icons.monitor_weight_rounded,
      CareTaskCategory.medication => Icons.medication_rounded,
    };

/// Canine preventive care schedule: vaccinations, deworming, flea & tick prevention,
/// and hygiene wellness tasks.
class PreventiveCareScreen extends ConsumerWidget {
  const PreventiveCareScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(careTaskControllerProvider(dogId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          '$dogName\'s Care Routine',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: tasksAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonBox(height: 72, borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load preventive care tasks.",
            onRetry: () => ref.invalidate(careTaskControllerProvider(dogId)),
          ),
          data: (tasks) {
            final pending = tasks.where((t) => !t.completed).toList();
            final done = tasks.where((t) => t.completed).toList();

            if (tasks.isEmpty) {
              return const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Nothing scheduled',
                message: 'Preventive care tasks will appear here as they come due.',
              );
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              children: [
                if (pending.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2210B981) : AppColors.pastelMint,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Caught Up! 🐶',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF181A20),
                                ),
                              ),
                              Text(
                                '$dogName has completed all active preventive healthcare milestones.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white70 : const Color(0xFF57534E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Upcoming & Due Tasks',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final task in pending) _TaskTile(task: task, dogId: dogId),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Completed Routine Care',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final task in done) _TaskTile(task: task, dogId: dogId),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task, required this.dogId});

  final CareTask task;
  final String dogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = task.completed
        ? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText)
        : task.isOverdue
            ? const Color(0xFFF43F5E)
            : const Color(0xFF0F766E);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(task.category), color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.category.label} · ${task.completed ? 'Completed' : task.isOverdue ? 'Overdue' : 'Due ${DateFormat('MMM d').format(task.dueDate)}'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (!task.completed)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(careTaskControllerProvider(dogId).notifier).markDone(task.id);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Mark Done',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
        ],
      ),
    );
  }
}
