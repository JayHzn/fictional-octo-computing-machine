class Appointment {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;
  final String? location;
  final String? childId;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    this.subtitle,
    this.location,
    this.childId,
  });
}