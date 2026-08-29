import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';

/// Appointment booking flow (brief §18): service/date/time selection,
/// confirmation, and a demo payment summary — this is a UI prototype with
/// no backend, so nothing here processes a real payment.
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
  String? _selectedTimeSlot;

  static const _timeSlots = ['9:00 AM', '10:30 AM', '1:00 PM', '2:30 PM', '4:00 PM', '5:30 PM'];

  Future<void> _pickDate() async {
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
      AppFeedback.showToast(context, title: 'Select a time', message: 'Please choose a time slot to continue.', type: ToastType.warning);
      return;
    }

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
      error: (_, _) => AppFeedback.showToast(context, title: 'Booking failed', message: 'Please try again.', type: ToastType.warning),
      loading: () {},
    );
  }

  void _showSuccess(DateTime dateTime) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
        title: const Text('Appointment Confirmed'),
        content: Text(
          '${widget.vet.name} · ${DateFormat('EEE, MMM d · h:mm a').format(dateTime)}\n${_selectedType.label}',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
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
      appBar: AppBar(title: const Text('Book Consultation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Consultation Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: widget.vet.consultationTypes
                .map((type) => ChoiceChip(
                      label: Text(type.label),
                      selected: _selectedType == type,
                      onSelected: (_) => setState(() => _selectedType = type),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Date', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_rounded, size: 16),
            label: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Time', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots
                .map((slot) => ChoiceChip(
                      label: Text(slot),
                      selected: _selectedTimeSlot == slot,
                      onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Payment', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text('Demo card on file · •••• 4242', style: theme.textTheme.bodyMedium)),
                Text('\$${widget.vet.consultationFeeUsd.toStringAsFixed(0)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          FilledButton(
            onPressed: isBooking ? null : _confirm,
            child: isBooking
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
