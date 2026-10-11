/// Validasi isian formulir. Mengembalikan pesan galat, atau `null` bila benar.
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String value) =>
      value.trim().isEmpty ? 'Nama panggilan belum diisi.' : null;

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email belum diisi.';
    if (!_emailPattern.hasMatch(v)) {
      return 'Format email belum benar. Contoh: nama@email.com';
    }
    return null;
  }

  static String? passwordRequired(String value) =>
      value.trim().isEmpty ? 'Kata sandi belum diisi.' : null;

  static String? newPassword(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Kata sandi belum diisi.';
    if (v.length < 6) return 'Kata sandi minimal 6 karakter.';
    return null;
  }
}
