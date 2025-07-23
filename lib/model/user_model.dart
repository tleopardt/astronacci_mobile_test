class DetailUser {
  final String firstName;
  final String lastName;
  final String birthDate;
  final String phone;
  final String email;
  final String? dirImage;

  DetailUser ({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    required this.email,
    this.dirImage,
  });

  factory DetailUser.fromJson(Map<String, dynamic> json) {
    return DetailUser(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthDate: json['birth_date'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      dirImage: json['dir_image'],
    );
  }
}