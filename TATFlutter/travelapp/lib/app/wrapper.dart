
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:travelapp/pages/login.dart';
// import 'package:travelapp/dashboards/homepage.dart';
// import 'package:travelapp/pages/verifyemail.dart';

// class Wrapper extends StatefulWidget {
//   const Wrapper({super.key});

//   @override
//   State<Wrapper> createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   bool? isManualLoggedIn;

//   @override
//   void initState() {
//     super.initState();
//     _checkManualLogin();
//   }
// Future<void> _checkManualLogin() async {
//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isManualLoggedIn') ?? false;
//   final token = prefs.getString('auth_token');
  
//   setState(() => isManualLoggedIn = isLoggedIn && token != null && token.isNotEmpty);
// }

 
// //   @override
// //   Widget build(BuildContext context) {
// //     final firebaseUser = FirebaseAuth.instance.currentUser;

// //     // Show loading while checking shared prefs
// //     if (isManualLoggedIn == null) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     if (firebaseUser != null) {
// //       return firebaseUser.emailVerified ? const Homepage() : const Verify();
// //     }

// //     if (isManualLoggedIn == true) {
// //       return const Homepage(); // manually logged in
// //     }

// //     return const Login(); // not logged in
// //   }
// // }


// @override
// Widget build(BuildContext context) {
//   return FutureBuilder(
//     future: SharedPreferences.getInstance(),
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) {
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       }

//       final prefs = snapshot.data!;
//       final isManualLoggedIn = prefs.getBool('isManualLoggedIn') ?? false;
//       final token = prefs.getString('auth_token');
//       final isTokenValid = isManualLoggedIn && token != null && token.isNotEmpty;

//       final firebaseUser = FirebaseAuth.instance.currentUser;

//       if (firebaseUser != null) {
//         return firebaseUser.emailVerified ? const Homepage() : const Verify();
//       }

//       if (isTokenValid) return const Homepage();

//       return const Login();
//     },
//   );
// }
// }


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:travelapp/pages/login.dart';
// import 'package:travelapp/dashboards/homepage.dart';
// import 'package:travelapp/pages/verifyemail.dart';

// class Wrapper extends StatelessWidget {
//   const Wrapper({super.key});

//   Future<Widget> _determineStartScreen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final method = prefs.getString('auth_method');
//     final token = prefs.getString('auth_token');

//     final firebaseUser = FirebaseAuth.instance.currentUser;

//     // Case 1: Firebase user
//     if (method == 'firebase' && firebaseUser != null) {
//       if (firebaseUser.emailVerified) {
//         return const Homepage();
//       } else {
//         return const Verify();
//       }
//     }

//     // Case 2: Manual login user with valid token
//     if (method == 'jwt' && token != null && token.isNotEmpty) {
//       return const Homepage();
//     }

//     // Default: Not logged in
//     return const Login();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Widget>(
//       future: _determineStartScreen(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         return snapshot.data!;
//       },
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/pages/login.dart';
import 'package:travelapp/dashboards/homepage.dart';
import 'package:travelapp/pages/verifyemail.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

Future<Widget> _determineStartScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final method = prefs.getString('auth_method');
  final token = prefs.getString('auth_token');

  debugPrint('Wrapper auth_method: $method');
  debugPrint('Wrapper auth_token: ${token != null ? 'Exists' : 'Null'}');

  final firebaseUser = FirebaseAuth.instance.currentUser;
  debugPrint('Wrapper Firebase user: ${firebaseUser?.uid ?? 'No user'}');

  // ✅ Handle Firebase login properly
  if (method == 'firebase' && firebaseUser != null) {
    await firebaseUser.reload();
    if (firebaseUser.emailVerified) {
      debugPrint('✅ Firebase user email is verified. Redirecting to Homepage.');
      return const Homepage();
    } else {
      debugPrint('⚠️ Firebase email not verified. Redirecting to Verify page.');
      return const Verify();
    }
  }

  // ✅ Handle manual JWT login
  if (method == 'jwt' && token != null && token.isNotEmpty) {
    debugPrint('✅ JWT token exists. Redirecting to Homepage.');
    return const Homepage();
  }

  // ❌ No valid auth found
  debugPrint('❌ No valid auth found. Redirecting to Login.');
  return const Login();
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          debugPrint('Wrapper FutureBuilder error: ${snapshot.error}');
          // Show error UI or fallback login page
          return const Login();
        }
        return snapshot.data!;
      },
    );
  }
}
