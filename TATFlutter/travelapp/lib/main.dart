// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; 
// import 'package:travelapp/app/wrapper.dart';
// import 'package:get/get.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform, 
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp( MyApp());

// }


// class MyApp extends StatelessWidget {
//    const MyApp({super.key});


//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Travel App',
//       home: Wrapper(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:travelapp/app/wrapper.dart';
import 'package:get/get.dart';
import 'package:travelapp/pages/login.dart'; // <-- import Login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const Wrapper()),
        GetPage(name: '/login', page: () => const Login()), // ✅ registered here
        // Add more GetPages here if needed
      ],
    );
  }
}
