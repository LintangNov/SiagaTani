import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:siaga_tani/view/main_screen.dart';
import 'package:siaga_tani/view/on_boarding.dart';
import '../core/utils/ui_utils.dart';

/// Kegagalan autentikasi dengan pesan Indonesia yang siap ditampilkan.
class AuthFailure {
  const AuthFailure(this.message, {this.code = ''});

  final String message;
  final String code;

  bool get emailAlreadyInUse => code == 'email-already-in-use';
}

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);

    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const OnboardingScreen());
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  static const _offlineMessage =
      'Tidak ada koneksi internet. Periksa jaringan Anda, lalu coba lagi.';

  bool _isNetworkError(Object e) {
    if (e is FirebaseAuthException) return e.code == 'network-request-failed';
    final text = e.toString().toLowerCase();
    return text.contains('network_error') || text.contains('network');
  }

  AuthFailure _loginFailure(Object e) {
    if (_isNetworkError(e)) return const AuthFailure(_offlineMessage);
    final code = e is FirebaseAuthException ? e.code : '';
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return AuthFailure(
          'Email atau kata sandi salah. Silakan coba lagi.',
          code: code,
        );
      case 'too-many-requests':
        return AuthFailure(
          'Terlalu banyak percobaan masuk. Tunggu beberapa menit, lalu coba lagi.',
          code: code,
        );
      case 'user-disabled':
        return AuthFailure(
          'Akun ini tidak dapat dipakai. Hubungi bantuan.',
          code: code,
        );
      default:
        return AuthFailure(
          'Belum bisa masuk. Silakan coba lagi beberapa saat lagi.',
          code: code,
        );
    }
  }

  AuthFailure _registerFailure(Object e) {
    if (_isNetworkError(e)) return const AuthFailure(_offlineMessage);
    final code = e is FirebaseAuthException ? e.code : '';
    if (code == 'email-already-in-use') {
      return AuthFailure(
        'Email ini sudah terdaftar. Silakan masuk, atau gunakan email lain.',
        code: code,
      );
    }
    return AuthFailure(
      'Pendaftaran belum berhasil. Silakan coba lagi beberapa saat lagi.',
      code: code,
    );
  }

  // --- REGISTER EMAIL & PASSWORD ---
  /// Mengembalikan `null` bila berhasil, atau kegagalan siap tampil.
  Future<AuthFailure?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);

      UiUtils.showSuccess('Selamat datang, $name!');
      return null;
    } catch (e) {
      debugPrint('register error: $e');
      return _registerFailure(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN EMAIL & PASSWORD ---
  Future<AuthFailure?> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      debugPrint('login error: $e');
      return _loginFailure(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- GOOGLE SIGN IN ---
  /// Dibatalkan pengguna dianggap berhasil tanpa pesan (mengembalikan `null`).
  Future<AuthFailure?> googleSignIn() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } catch (e) {
      debugPrint('google sign-in error: $e');
      if (_isNetworkError(e)) return const AuthFailure(_offlineMessage);
      return const AuthFailure(
        'Tidak bisa masuk dengan Google. Silakan coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
