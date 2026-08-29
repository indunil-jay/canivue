import 'package:canivue/features/vets/domain/veterinarian.dart';

class VetSearchFilters {
  const VetSearchFilters({this.specialty, this.availableTodayOnly = false, this.consultationType});

  final String? specialty;
  final bool availableTodayOnly;
  final ConsultationType? consultationType;
}

abstract class VetRepository {
  Future<List<Veterinarian>> search(String query, VetSearchFilters filters);

  Future<Veterinarian> fetchVet(String id);
}
