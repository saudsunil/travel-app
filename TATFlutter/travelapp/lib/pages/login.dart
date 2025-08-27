


  // // Email/Password Sign In
  // Future<void> signInWithEmail() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: identifierController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );

  //     // Get Firebase ID Token and send to Django backend
  //     final idToken = await userCredential.user!.getIdToken();

  //     final response = await http.post(
  //       Uri.parse("http://192.168.18.7:8000/user/auth/firebase-login/"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'idToken': idToken}),
  //     );

  //     if (response.statusCode == 200) {
  //       log("Login success: ${response.body}");
  //       Get.offAll(() => const Wrapper());
  //     } else {
  //       final error = jsonDecode(response.body);
  //       showError(error['error'] ?? 'Login failed');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     showError(e.message ?? 'Email sign-in failed');
  //   } catch (e) {
  //     showError(e.toString());
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelapp/pages/forgotpw.dart';
import 'package:travelapp/pages/signup.dart';
import 'package:travelapp/app/wrapper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

// ... [all imports remain unchanged]

class _LoginState extends State<Login> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.white,
      colorText: Colors.red,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

 Future<void> manualLogin() async {
  FocusScope.of(context).unfocus();
  await Future.delayed(const Duration(milliseconds: 100));

  final identifier = identifierController.text.trim();
  final password = passwordController.text.trim();

  if (identifier.isEmpty || password.isEmpty) {
    showError("Please enter both identifier and password");
    return;
  }

  setState(() => isLoading = true);

  final stopwatch = Stopwatch()..start(); // ⏱️ Start timing here

  try {
    debugPrint('⏳ Sending login request...');
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/user/auth/manual-login/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    stopwatch.stop(); // ⏹️ Stop timing once response is received

    debugPrint('⏱ Login API took ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('📩 Response status: ${response.statusCode}');
    debugPrint('📦 Response body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = data['user'];
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_method', 'jwt');
      await prefs.setString('auth_token', token);
      await prefs.setString('manualUserEmail', user['email']);

      Get.offAll(() => const Wrapper());
    } else {
      showError(data['error'] ?? 'Login failed');
    }
  } catch (e) {
    stopwatch.stop(); // Just in case exception happens before stop
    debugPrint('❌ Exception during login: $e');
    showError(e.toString());
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    debugPrint('🟡 [GoogleLogin] Starting Google Sign-In');

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint('🛑 [GoogleLogin] Sign-In cancelled');
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      debugPrint('🔐 [GoogleLogin] Got Google credentials');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      debugPrint('✅ [GoogleLogin] Firebase user: ${firebaseUser.uid}');

      String? idToken;
      try {
        idToken = await firebaseUser.getIdToken(true);
        debugPrint('🔐 [GoogleLogin] Firebase ID token obtained');
      } catch (e) {
        debugPrint('⚠️ [GoogleLogin] Token fetch error, retrying...');
        await FirebaseAuth.instance.currentUser?.reload();
        idToken = await firebaseUser.getIdToken(true);
      }

      debugPrint('⏳ [GoogleLogin] Sending ID token to backend...');
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/auth/google-login/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'email': firebaseUser.email,
          'username': firebaseUser.displayName ?? firebaseUser.email?.split('@')[0],
        }),
      );

      debugPrint('📩 [GoogleLogin] Status: ${response.statusCode}');
      debugPrint('📦 [GoogleLogin] Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('✅ [GoogleLogin] Login success');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_method', 'firebase');
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('manualUserEmail', firebaseUser.email ?? '');

        debugPrint('📥 [GoogleLogin] Token stored, navigating to Wrapper...');
        Get.offAll(() => const Wrapper());
      } else {
        debugPrint('❌ [GoogleLogin] Error: ${responseData['error']}');
        showError(responseData['error'] ?? 'Google login failed');
      }
    } catch (e, stacktrace) {
      debugPrint('❌ [GoogleLogin] Exception: $e');
      debugPrint('$stacktrace');
      showError('An error occurred during Google login.');
    } finally {
      setState(() => isLoading = false);
      debugPrint('🟢 [GoogleLogin] Completed');
    }
  }


  Widget buildEmailPasswordFields() {
    return Column(
      children: [
        TextField(
          controller: identifierController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(labelText: 'Email or Username'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon:
                  Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => const Forgotpw()),
            child: const Text('Forgot Password?'),
          ),
        ),
      ],
    );
  }

  Widget buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: signInWithGoogle,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                "Continue with Google",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                left: 10,
                child: Container(
                  height: 43,
                  width: 43,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset('assets/images/google_logo.svg'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDividerWithText() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('or'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 60),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      buildEmailPasswordFields(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: manualLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 16),
                      buildDividerWithText(),
                      const SizedBox(height: 16),
                      buildGoogleSignInButton(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () => Get.to(() => const Signup()),
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
