class Child {
  final String id;
  final String firstName;
  final DateTime birthDate;
  final String? photoUrl;

  Child({
    required this.id,
    required this.firstName,
    required this.birthDate,
    this.photoUrl,
  });
}