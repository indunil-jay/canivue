import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';

/// Appointment booking flow: service type, date, time slot, payment preview,
/// and booking confirmation dialog.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.vet, required this.dogId, required this.dogName});

  final Veterinarian vet;
  final String dogId;
  final String dogName;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late ConsultationType _selectedType = widget.vet.consultationTypes.first;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot = '10:30 AM';

  static const _timeSlots = ['9:00 AM', '10:30 AM', '1:00 PM', '2:30 PM', '4:00 PM', '5:30 PM'];

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _confirm() async {
    if (_selectedTimeSlot == null) {
      AppFeedback.showToast(
        context,
        title: 'Select a time slot',
        message: 'Please choose a consultation time to proceed.',
        type: ToastType.warning,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final time = DateFormat('h:mm a').parse(_selectedTimeSlot!);
    final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute);

    await ref.read(appointmentBookingControllerProvider.notifier).book(
          vetId: widget.vet.id,
          vetName: widget.vet.name,
          dogId: widget.dogId,
          dogName: widget.dogName,
          dateTime: dateTime,
          consultationType: _selectedType,
          feeUsd: widget.vet.consultationFeeUsd,
        );

    if (!mounted) return;

    final result = ref.read(appointmentBookingControllerProvider);
    result.when(
      data: (appointment) {
        if (appointment != null) _showSuccess(dateTime);
      },
      error: (_, _) => AppFeedback.showToast(
        context,
        title: 'Booking failed',
        message: 'Please try again.',
        type: ToastType.warning,
      ),
      loading: () {},
    );
  }

  void _showSuccess(DateTime dateTime) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
        title: Text(
          'Appointment Confirmed',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          '${widget.vet.name}\n${DateFormat('EEE, MMM d · h:mm a').format(dateTime)}\n${_selectedType.label}',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
        ),
        actions: [
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF181A20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Done',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final booking = ref.watch(appointmentBookingControllerProvider);
    final isBooking = booking.isLoading;

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
          'Book Consultation',
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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            // Doctor Summary Card
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
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.vet.initials,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vet.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${widget.vet.specialty} · for ${widget.dogName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Consultation Mode
            _sectionLabel('Consultation Format', isDark),
            const SizedBox(height: 8),
            Row(
              children: widget.vet.consultationTypes.map((type) {
                final selected = _selectedType == type;
                final isVideo = type == ConsultationType.video;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedType = type);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? (isDark ? Colors.white : const Color(0xFF181A20))
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? (isDark ? Colors.white : const Color(0xFF181A20))
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                                color: selected
                                    ? (isDark ? const Color(0xFF181A20) : Colors.white)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                  color: selected
                                      ? (isDark ? const Color(0xFF181A20) : Colors.white)
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date Selection
            _sectionLabel('Select Date', isDark),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0F766E)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Tap to reschedule date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots
            _sectionLabel('Select Time Slot', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final selected = _selectedTimeSlot == slot;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTimeSlot = slot);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? (isDark ? Colors.white : const Color(0xFF181A20))
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? (isDark ? Colors.white : const Color(0xFF181A20))
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected
                              ? (isDark ? const Color(0xFF181A20) : Colors.white)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Payment Preview Card
            _sectionLabel('Payment Summary', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
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
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x228B5CF6) : AppColors.pastelLilac,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.credit_card_rounded, color: Color(0xFF7A67EE), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo payment on file',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Visa ending in •••• 4242',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${widget.vet.consultationFeeUsd.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            FilledButton(
              onPressed: isBooking ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
              ),
              child: isBooking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : Text(
                      'Confirm Appointment',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }
}
