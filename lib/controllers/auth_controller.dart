import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:siaga_tani/view/main_screen.dart';
import 'package:siaga_tani/view/on_boarding.dart';
import '../utils/ui_utils.dart'; 

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


  _setInitialScreen(User? user) {
    if (user == null) {
      
      Get.offAll(() => const OnboardingScreen());
    } else {

      Get.offAll(() => const MainScreen());
    }
  }

  // --- REGISTER EMAIL & PASSWORD ---
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user!.updateDisplayName(name);
      
      UiUtils.showSuccess("Akun berhasil dibuat! Selamat datang, $name.");
    } catch (e) {
      UiUtils.showError("Gagal daftar: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN EMAIL & PASSWORD ---
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      UiUtils.showSuccess("Login berhasil!");
    } catch (e) {
      UiUtils.showError("Login gagal. Cek email/password Anda.");
    } finally {
      isLoading.value = false;
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      UiUtils.showSuccess("Berhasil masuk dengan Google!");
    } catch (e) {
      UiUtils.showError("Google Sign-In Error: $e");
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