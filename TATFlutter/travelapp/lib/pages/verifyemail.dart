// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:travelapp/app/wrapper.dart';

// class Verify extends StatefulWidget {
//   const Verify({super.key});

//   @override
//   State<Verify> createState() => _VerifyState();
// }

// class _VerifyState extends State<Verify> {
//   @override
//   void initState() {
//     sendverifylink();
//     super.initState();
//   }

//   sendverifylink() async {
//     final user = FirebaseAuth.instance.currentUser!;
//     await user.sendEmailVerification().then((value) {
//       Get.snackbar(
//         'Link sent',
//         'A link has been sent to your email',
//         backgroundColor: Colors.white,
//         colorText: Colors.green,
//         margin: EdgeInsets.all(30),
//         snackPosition: SnackPosition.TOP,
//       );
//     });
//   }

//   reload() async {
//     final user= FirebaseAuth.instance.currentUser!;
//       await user.reload();
//   if (user.emailVerified) { 
//       Get.offAll(Wrapper());
//     }
//     else {
//     Get.snackbar(
//       "Verification Pending",
//       "Email is not yet verified, please check your inbox.",
//       backgroundColor: Colors.white,
//       colorText: Colors.orange,
//       snackPosition: SnackPosition.TOP,
//       margin: EdgeInsets.all(16),
//     );
//   }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify your email.")),
//       body: Padding(
//         padding: const EdgeInsets.all(28.0),
//         child: Center(
//           child: Text(
//             'Open your mail and click on the link provided to verify email and reload this page after success!',
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (() => reload()),
//         child: Icon(Icons.restart_alt_rounded),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:travelapp/app/wrapper.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool _linkSent = false;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    sendVerifyLinkOnce();
  }

  void sendVerifyLinkOnce() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified && !_linkSent) {
      try {
        await user.sendEmailVerification();
        setState(() => _linkSent = true);
        Get.snackbar(
          'Link Sent',
          'A verification link has been sent to your email.',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          margin: const EdgeInsets.all(20),
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to send verification email.',
          backgroundColor: Colors.white,
          colorText: Colors.red,
          margin: const EdgeInsets.all(20),
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  Future<void> reload() async {
    setState(() {
      _isReloading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _isReloading = false;
    });

    if (refreshedUser != null && refreshedUser.emailVerified) {
      Get.snackbar(
        'Success',
        'Account created successfully',
        backgroundColor: Colors.white,
        colorText: Colors.green,
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.TOP,
      );
      Get.offAll(() => const Wrapper());
    } else {
      Get.snackbar(
        "Verification Pending",
        "Email is not yet verified. Please check your inbox.",
        backgroundColor: Colors.white,
        colorText: Colors.orange,
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Text(
            'Open your email and click the link we sent to verify your account. Once done, tap the button below to reload and continue.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isReloading ? null : reload,
        tooltip: "Reload",
        child: _isReloading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.restart_alt_rounded),
      ),
    );
  }
}
