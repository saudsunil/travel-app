
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:travelapp/pages/login.dart';
// import 'package:travelapp/app/wrapper.dart';
// import 'dart:convert';         // For jsonEncode and jsonDecode
// import 'package:http/http.dart' as http; 
// import 'package:travelapp/pages/verifyemail.dart'; // For making HTTP requests

// // Import your snackbar utils here:
// import 'package:travelapp/utils/showerror.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});

//   @override
//   State<Signup> createState() => _SignupState();
// }

// class _SignupState extends State<Signup> {
//   TextEditingController email = TextEditingController();
//   TextEditingController username = TextEditingController();
//   TextEditingController password = TextEditingController();
//   TextEditingController confirmPassword = TextEditingController();

//   bool isloading = false;
//   bool obscurePassword = true;
//   bool obscureConfirmPassword = true;
//   bool useEmail = true;

// Future<void> signUpWithEmail() async {
//   if (password.text != confirmPassword.text) {
//     showError("Passwords do not match");
//     return;
//   }
//   if (username.text.trim().isEmpty) {
//     showError("Username cannot be empty");
//     return;
//   }

//   setState(() {
//     isloading = true;
//   });

//   try {
//     // Create user in Firebase
//     await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email.text.trim(),
//       password: password.text,
//     );

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       showError("Failed to get Firebase user.");
//       return;
//     }

//     final firebaseidToken = await currentUser.getIdToken(true);

//     // Send token+username to Django backend
//     final response = await http.post(
//       Uri.parse("http://192.168.18.7:8000/user/auth/firebase-signup/"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'id_token':firebaseidToken, // ✅ FIXED KEY
//         'username': username.text.trim(),
//         'password': password.text,
//       }),
//     );

//     print("Response status: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 200) {

//       Get.offAll(Wrapper());
//     } else {
//       final err = jsonDecode(response.body);
//       showError(err['error'] ?? "Unknown error");
//     }
//   } on FirebaseAuthException catch (e) {
//     showError(e.code);
//   } catch (e) {
//     showError(e.toString());
//   } finally {
//     setState(() => isloading = false);
//   }
// }




 

//   Future<void> signUpWithGoogle() async {
//   setState(() => isloading = true);

//   try {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) {
//       setState(() => isloading = false);
//       return;
//     }

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Sign in to Firebase
//     final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//      final firebaseUser = userCredential.user;

//     if (firebaseUser == null) {
//       showError("Firebase sign-in failed");
//       setState(() => isloading = false);
//       return;
//     }
//       // ✅ This was the error: it must be here before using it in JSON
//     final firebaseIdToken = await firebaseUser.getIdToken();


//     // ✅ Send ID token to your Django backend
//     final response = await http.post(
//       Uri.parse("http://192.168.18.7:8000/user/auth/google-login/"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'id_token': firebaseIdToken,
//                         'email': firebaseUser.email,
//                         'username': firebaseUser.displayName ?? firebaseUser.email!.split('@')[0]
//       }),
//     );

//     if (response.statusCode == 200) {
//       print ("User saved in Django: ${response.body}");
//       Get.offAll(() => const Wrapper());
//     } else {
//       print("🔥 Response: ${response.body}");
//       showError("Backend Error: ${response.body}");
//     }
//   } catch (e) {
//     showError(e.toString());
//   } finally {
//     setState(() => isloading = false);
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Signup")),
//       body: isloading
//           ? Center(child: CircularProgressIndicator())
//           : Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(30, 0, 30, 60),
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children:[
                    
//                        TextField(
//                         controller: email,
//                         decoration: InputDecoration(labelText: 'Email'),
//                         ),
//                         SizedBox(height: 16),
                    
                       

                      
//                       TextField(
//                         controller: username,
//                         decoration: InputDecoration(labelText: 'Username'),
//                       ),
//                       SizedBox(height: 16),

//                       // Password
//                       TextField(
//                         controller: password,
//                         obscureText: obscurePassword,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           suffixIcon: IconButton(
//                             icon: Icon(obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility),
//                             onPressed: () {
//                               setState(() {
//                                 obscurePassword = !obscurePassword;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Confirm Password
//                       TextField(
//                         controller: confirmPassword,
//                         obscureText: obscureConfirmPassword,
//                         decoration: InputDecoration(
//                           labelText: 'Confirm Password',
//                           suffixIcon: IconButton(
//                             icon: Icon(obscureConfirmPassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility),
//                             onPressed: () {
//                               setState(() {
//                                 obscureConfirmPassword = !obscureConfirmPassword;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 30),
                      
    
//                         ElevatedButton(
//                           onPressed: () async{
//                              await signUpWithEmail();
//                          // only if signUp successful, navigate to Verify
//                          if (FirebaseAuth.instance.currentUser != null) {
//                            Get.to(Verify());
//                          }
                     

//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 45),
//                           ),
//                           child: const Text('Signup'),
//                         ),
                  
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(child: Divider()),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text("or"),
//                           ),
//                           Expanded(child: Divider()),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: GestureDetector(
//                           onTap: signUpWithGoogle,
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               border: Border.all(color: Colors.grey.shade300),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Text(
//                                   "Continue with Google",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 Positioned(
//                                   left: 10,
//                                   child: Container(
//                                     height: 43,
//                                     width: 43,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: SvgPicture.asset(
//                                       'assets/images/google_logo.svg',
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Already have an account?"),
//                           TextButton(
//                             onPressed: () => Get.to(Login()),
//                             child: Text("Login"),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelapp/pages/login.dart';
import 'package:travelapp/app/wrapper.dart';
import 'package:travelapp/pages/verifyemail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelapp/utils/showerror.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool isloading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> signUpWithEmail() async {
    if (password.text != confirmPassword.text) {
      showError("Passwords do not match");
      return;
    }
    if (username.text.trim().isEmpty) {
      showError("Username cannot be empty");
      return;
    }

    setState(() => isloading = true);

    try {
      // Firebase signup
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showError("Failed to get Firebase user.");
        return;
      }

      final firebaseIdToken = await currentUser.getIdToken(true);

      // Send to Django backend
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/auth/firebase-signup/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': firebaseIdToken,
          'username': username.text.trim(),
          'password': password.text,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to verify page only after signup success
        Get.to(() => const Verify());
      } else {
        final err = jsonDecode(response.body);
        showError(err['error'] ?? "Unknown error");
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? e.code);
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => isloading = false);
    }
  }

  Future<void> signUpWithGoogle() async {
    setState(() => isloading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isloading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        showError("Firebase sign-in failed");
        return;
      }

      final idToken = await firebaseUser.getIdToken(true);

      // Send to Django backend
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/auth/google-login/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token':idToken,
          'email': firebaseUser.email,
          'username': firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAll(() => const Wrapper());
      } else {
        final err = jsonDecode(response.body);
        showError(err['error'] ?? "Unknown error from backend");
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 60),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: username,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: password,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: confirmPassword,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: signUpWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('Signup'),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("or"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: signUpWithGoogle,
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
                                  child: SvgPicture.asset(
                                    'assets/images/google_logo.svg',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () => Get.to(() => const Login()),
                          child: const Text("Login"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
