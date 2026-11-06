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
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';
import 'package:canivue/features/predictions/presentation/controllers/prediction_controller.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_status_badge.dart';

/// Full AI-analysis history for one dog — every past prediction with its status,
/// confidence, category, date, multi-model breakdown and DPRPE progression risk.
///
/// Designed with the warm sanctuary aesthetic and tactile Apple-style motion.
class PredictionHistoryScreen extends ConsumerStatefulWidget {
  const PredictionHistoryScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  ConsumerState<PredictionHistoryScreen> createState() => _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState extends ConsumerState<PredictionHistoryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Attention', 'Monitoring', 'Resolved'];

  void _onLaunchScan() {
    HapticFeedback.mediumImpact();
    final samplePet = Pet.samplePets.firstWhere(
      (p) => p.id == widget.dogId,
      orElse: () => Pet.samplePets.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: Pet.samplePets, initialPet: samplePet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(predictionHistoryProvider(widget.dogId));
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
          '${widget.dogName}\'s AI Diagnostics',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF181A20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'Run New AI Check',
            onPressed: _onLaunchScan,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: historyAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 110))),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load the AI diagnostic history.",
            onRetry: () => ref.invalidate(predictionHistoryProvider(widget.dogId)),
          ),
          data: (predictions) {
            if (predictions.isEmpty) {
              return EmptyState(
                icon: Icons.auto_awesome_rounded,
                title: 'No AI predictions yet',
                message: 'Run an AI health check to generate the first fused diagnostic for ${widget.dogName}.',
                actionLabel: 'Run AI Health Check',
                onAction: _onLaunchScan,
              );
            }

            final filtered = predictions.where((p) {
              if (_selectedFilterIndex == 1) {
                return p.status == PredictionStatus.highRisk || p.status == PredictionStatus.moderateRisk;
              } else if (_selectedFilterIndex == 2) {
                return p.status == PredictionStatus.monitoring || p.status == PredictionStatus.vetReviewRecommended;
              } else if (_selectedFilterIndex == 3) {
                return p.status == PredictionStatus.resolved;
              }
              return true;
            }).toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              children: [
                // 1. AI Diagnostics Cockpit Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF222834), Color(0xFF191D26)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF181A20), Color(0xFF232730)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFFED25E).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED25E).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFED25E), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Canive Multimodal AI Engine',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFED25E),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'v2.3 Fusion',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${predictions.length} Total AI Diagnostics',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Multimodal synthesis of computer vision, continuous smart collar vitals, and owner symptom reports.',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _onLaunchScan,
                          icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF181A20)),
                          label: Text(
                            'Run New AI Health Check',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: const Color(0xFF181A20),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFED25E),
                            foregroundColor: const Color(0xFF181A20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Filter Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedFilterIndex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilterIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20))
                                : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFEAE5DC)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              _filters[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                    : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Diagnostic Entries List
                for (final prediction in filtered) ...[
                  _HistoryEntry(prediction: prediction),
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryEntry extends StatefulWidget {
  const _HistoryEntry({required this.prediction});

  final Prediction prediction;

  @override
  State<_HistoryEntry> createState() => _HistoryEntryState();
}

class _HistoryEntryState extends State<_HistoryEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PredictionCard(prediction: widget.prediction, initiallyExpanded: true),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = false);
              },
              icon: const Icon(Icons.expand_less_rounded, size: 18),
              label: Text(
                'Collapse Breakdown',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
          ),
        ],
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prediction = widget.prediction;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _expanded = true);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242A38) : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prediction.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: isDark ? Colors.white : const Color(0xFF181A20),
                          ),
                        ),
                      ),
                      PredictionStatusBadge(status: prediction.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${prediction.category} · ${prediction.confidencePercent.round()}% confidence · ${DateFormat('MMM d, yyyy').format(prediction.predictionDate)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  if (prediction.outcomeNote != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Outcome: ${prediction.outcomeNote}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
