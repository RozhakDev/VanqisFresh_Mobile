/// Merepresentasikan profil pengguna aplikasi.
///
/// Model ini dipakai untuk data akun yang sedang login.
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat User perlu dibuat dengan nilai awal.
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
  });

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat User perlu dibuat dengan nilai awal.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}
