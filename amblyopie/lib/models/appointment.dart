class Appointment {
  final String id;
  final String title;
  final DateTime date;
  final String? location;
  final String? childId;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    this.location,
    this.childId,
  });
}