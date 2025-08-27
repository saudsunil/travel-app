
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import 'package:travelapp/pages/login.dart';
// import 'package:travelapp/dashboards/travelplace.dart';
// import 'package:travelapp/dashboards/useraddedplace.dart';
// import 'package:travelapp/dashboards/profile.dart';
// import 'package:travelapp/dashboards/searchuser.dart';
// import 'package:travelapp/dashboards/notification.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   User? firebaseUser = FirebaseAuth.instance.currentUser;
//   String? manualEmail;
//   int _currentIndex = 0;
//   int unreadCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     loadManualUser();
//     fetchUnreadCountFromNotifications();
//   }

//   Future<void> loadManualUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (firebaseUser == null) {
//       setState(() {
//         manualEmail = prefs.getString('manualUserEmail') ?? 'Guest';
//       });
//     }
//   }

//   Future<String?> getAuthToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }

//   // Fetch unread notification count dynamically from backend
//   Future<void> fetchUnreadCountFromNotifications() async {
//     final token = await getAuthToken();
//     if (token == null) {
//       setState(() {
//         unreadCount = 0;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/user/notifications/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         // Filter by 'is_read' field to get unread count
//         final unread = data.where((notif) => notif['is_read'] == false).length;
//         setState(() {
//           unreadCount = unread;
//         });
//       } else {
//         setState(() {
//           unreadCount = 0;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         unreadCount = 0;
//       });
//     }
//   }

//   Future<void> signOut() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (firebaseUser != null) {
//       await FirebaseAuth.instance.signOut();
//       await GoogleSignIn().signOut();
//     }
//     await prefs.remove('isManualLoggedIn');
//     await prefs.remove('manualUserEmail');
//     await prefs.remove('auth_token');
//     Get.offAll(() => const Login());
//   }

//   // Handle Bottom Nav Taps and refresh unread count on Notification page return
//   Future<void> handleBottomNavTap(int index) async {
//     if (index == 1) {
//       Get.to(() => const SearchUsersPage());
//     } else if (index == 2) {
//       await Get.to(() => const NotificationPage());
//       await fetchUnreadCountFromNotifications();
//     } else {
//       setState(() => _currentIndex = index);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SahaYatri"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.chat_bubble_outline),
//             onPressed: () {
//               // TODO: Add chat navigation
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'profile') {
//                 Get.to(() => const UserProfilePage());
//               } else if (value == 'logout') {
//                 signOut();
//               }
//             },
//             itemBuilder: (BuildContext context) => const [
//               PopupMenuItem(value: 'profile', child: Text('Profile')),
//               PopupMenuItem(value: 'logout', child: Text('Logout')),
//             ],
//             icon: const Icon(Icons.account_circle_outlined),
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: 10,
//               itemBuilder: (context, index) => Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 30,
//                       backgroundImage: AssetImage('assets/images/profilestory.png'),
//                     ),
//                     const SizedBox(height: 10),
//                     Text('User $index', style: const TextStyle(fontSize: 15)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.asset(
//                     'assets/images/nepal.png',
//                     height: 500,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             Get.to(() => const TravelPlacePage());
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green.shade700,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text("Let's Explore Nepal ?"),
//                         ),
//                         const SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: () {
//                             Get.to(() => const AddPlaceFormPage());
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green.shade700,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text("Let's Explore Your Places ?"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) async => await handleBottomNavTap(index),
//         selectedItemColor: Colors.green.shade700,
//         unselectedItemColor: Colors.grey,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.search_outlined),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.notifications_outlined),
//                 if (unreadCount > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(1),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade700,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 14,
//                         minHeight: 14,
//                       ),
//                       child: Text(
//                         unreadCount > 99 ? '99+' : unreadCount.toString(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Notification',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline),
//             label: 'Chat',
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:travelapp/pages/login.dart';
import 'package:travelapp/dashboards/travelplace.dart';
import 'package:travelapp/dashboards/useraddedplace.dart';
import 'package:travelapp/dashboards/profile.dart';
import 'package:travelapp/dashboards/searchuser.dart';
import 'package:travelapp/dashboards/notification.dart';
import 'package:travelapp/dashboards/searchuserprofile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  String? manualEmail;
  int _currentIndex = 0;
  int unreadCount = 0;

  List<Map<String, dynamic>> followedUsers = [];

  @override
  void initState() {
    super.initState();
    loadManualUser();
    fetchUnreadCountFromNotifications();
    fetchFollowedUsers();
  }

  Future<void> loadManualUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (firebaseUser == null) {
      setState(() {
        manualEmail = prefs.getString('manualUserEmail') ?? 'Guest';
      });
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchUnreadCountFromNotifications() async {
    final token = await getAuthToken();
    if (token == null) {
      debugPrint("No auth token found for notification count.");
      setState(() => unreadCount = 0);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/user/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final unread = data.where((notif) => notif['is_read'] == false).length;
        debugPrint("Unread notifications: $unread");
        setState(() => unreadCount = unread);
      } else {
        debugPrint("Failed to load notifications. Code: ${response.statusCode}");
        setState(() => unreadCount = 0);
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      setState(() => unreadCount = 0);
    }
  }

  Future<void> fetchFollowedUsers() async {
    final token = await getAuthToken();
    if (token == null) {
      debugPrint("No token found. Cannot fetch followed users.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/user/following/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

         debugPrint("📡 Response Status: ${response.statusCode}");
    debugPrint("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint("Followed users: ${data.length}");
        setState(() {
          followedUsers = List<Map<String, dynamic>>.from(data);
        });
      } else {
        debugPrint("Failed to fetch followed users. Code: ${response.statusCode}");
        setState(() => followedUsers = []);
      }
    } catch (e) {
      debugPrint("Error fetching followed users: $e");
      setState(() => followedUsers = []);
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    }
    await prefs.remove('isManualLoggedIn');
    await prefs.remove('manualUserEmail');
    await prefs.remove('auth_token');
    Get.offAll(() => const Login());
  }

  Future<void> handleBottomNavTap(int index) async {
    if (index == 1) {
      Get.to(() => const SearchUsersPage());
    } else if (index == 2) {
      await Get.to(() => const NotificationPage());
      await fetchUnreadCountFromNotifications();
    } else {
      setState(() => _currentIndex = index);
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("SahaYatri"),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            // TODO: Navigate to Chat
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              Get.to(() => const UserProfilePage());
            } else if (value == 'logout') {
              signOut();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profile', child: Text('Profile')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    ),
    body: ListView(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: followedUsers.isEmpty
              ? const Center(child: Text('No followed users'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: followedUsers.length,
                  itemBuilder: (context, index) {
                    final user = followedUsers[index];
                    final imageUrl = user['profile_image'] ?? '';
                    final username = user['username'] ?? 'User';

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => SearchUserProfilePage(userId: user['id']));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade300,
                              child: imageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.person, size: 30, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 30, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              username,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/nepal.png',
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => const TravelPlacePage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Let's Explore Nepal ?"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => const AddPlaceFormPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Let's Explore Your Places ?"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: handleBottomNavTap,
      selectedItemColor: Colors.green.shade700,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notification',
        ),
      ],
    ),
  );
}
}