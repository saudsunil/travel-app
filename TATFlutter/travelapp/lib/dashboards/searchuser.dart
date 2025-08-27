// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'package:firebase_auth/firebase_auth.dart';

// class SearchUsersPage extends StatefulWidget {
//   const SearchUsersPage({super.key});

//   @override
//   State<SearchUsersPage> createState() => _SearchUsersPageState();
// }

// class _SearchUsersPageState extends State<SearchUsersPage> {
//   List<dynamic> searchResults = [];
//   bool isLoading = false;
//   String query = "";
//   String? errorMessage;

//   Future<void> searchUsers(String q) async {
//     if (q.trim().isEmpty) return;

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     final firebaseUser = FirebaseAuth.instance.currentUser;
//     final token = await firebaseUser?.getIdToken(true);

//     if (token == null) {
//       setState(() {
//         errorMessage = "You must be logged in to search.";
//         isLoading = false;
//       });
//       return;
//     }

//     print("🔐 Using token: $token");

//     try {
//       final response = await http.get(
//         Uri.parse("http://192.168.18.7:8000/user/search/?q=$q"),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       print("🔍 Search Response: ${response.statusCode} | ${response.body}");

//       if (response.statusCode == 200) {
//         final List<dynamic> users = jsonDecode(response.body);
//         setState(() {
//           searchResults = users;
//           isLoading = false;
//         });
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = "Unauthorized. Please log in again.";
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = "Error: ${response.statusCode}";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "Error: $e";
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> toggleFollow(int userId, bool isFollowing) async {
//      final firebaseUser = FirebaseAuth.instance.currentUser;
//      final token = await firebaseUser?.getIdToken(true);

//     if (token == null) {
//       setState(() {
//         errorMessage = "Login required to follow/unfollow.";
//       });
//       return;
//     }

//     final url = isFollowing
//         ? "http://192.168.18.7:8000/user/unfollow/$userId/"
//         : "http://192.168.18.7:8000/user/follow/$userId/";

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       print("🔁 Follow Toggle Response: ${response.statusCode} | ${response.body}");

//       if (response.statusCode == 200) {
//         searchUsers(query); // Refresh list
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = "Session expired. Please log in again.";
//         });
//       } else {
//         setState(() {
//           errorMessage = "Unable to follow/unfollow.";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "Error: $e";
//       });
//     }
//   }




// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: const Text("Search Users")),
//     body: Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: TextField(
//             decoration: const InputDecoration(
//               hintText: 'Search by username or full name',
//               border: OutlineInputBorder(),
//               suffixIcon: Icon(Icons.search),
//             ),
//             onSubmitted: (val) {
//               query = val.trim();
//               if (query.isNotEmpty) {
//                 searchUsers(query);
//               }
//             },
//           ),
//         ),
//         if (isLoading)
//           const Center(child: CircularProgressIndicator())
//         else if (errorMessage != null)
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               errorMessage!,
//               style: const TextStyle(color: Colors.red),
//             ),
//           )
//         else if (searchResults.isEmpty)
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text("No users found."),
//           )
//         else
//           Expanded(
//             child: ListView.builder(
//               itemCount: searchResults.length,
//               itemBuilder: (context, index) {
//                 final user = searchResults[index];
//                 final profile = user['profile'] ?? {};
//                 final fullName = profile['full_name'] ?? '';
//                 final username = user['username'] ?? '';
//                 final photoUrlRaw = profile['photo_url'] ?? '';
//                 final isFollowing = profile['is_following'] ?? false;

//                 // Debug print user data (optional, remove in production)
//                 // print("User #$index: fullName='$fullName', username='$username', photoUrl='$photoUrlRaw'");

//                 // Fix URL for Android emulator if needed
//                 final photoUrl = photoUrlRaw.isNotEmpty
//                     ? photoUrlRaw.replaceFirst('192.168.18.7', '10.0.2.2')
//                     : '';

//                 return ListTile(
//                   leading: CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.grey[300],
//                     child: photoUrl.isEmpty
//                         ? const Icon(Icons.person, size: 24)
//                         : ClipOval(
//                             child: FadeInImage.assetNetwork(
//                               placeholder: 'assets/placeholder.png', // add a placeholder image to your assets folder
//                               image: photoUrl,
//                               width: 48,
//                               height: 48,
//                               fit: BoxFit.cover,
//                               imageErrorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.person, size: 24);
//                               },
//                             ),
//                           ),
//                   ),
//                   title: Text(
//                     fullName.isNotEmpty ? fullName : username,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text('@$username'),
//                   trailing: ElevatedButton(
//                     onPressed: () => toggleFollow(user['id'], isFollowing),
//                     child: Text(isFollowing ? "Unfollow" : "Follow"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           isFollowing ? Colors.grey : Colors.green.shade700,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//       ],
//     ),
//   );
// }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelapp/pages/crossauth.dart';
import 'searchuserprofile.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String query = "";
  String? errorMessage;

  Future<void> searchUsers(String q) async {
  if (q.trim().isEmpty) return;

  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  debugPrint("🔍 Starting user search for query: '$q'");

  final token = await getAuthToken();
  debugPrint("🔑 Token retrieved: ${token?.substring(0, 20)}...");

  if (token == null) {
    setState(() {
      errorMessage = "You must be logged in to search.";
      isLoading = false;
    });
    debugPrint("❌ No token found. Aborting search.");
    return;
  }

  try {
    final url = "http://10.0.2.2:8000/user/search/?q=$q";  // Updated here!
    debugPrint("🌐 Sending GET request to: $url");

    final response = await http
        .get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10)); // Add timeout here

    debugPrint("🔄 Response status: ${response.statusCode}");
    debugPrint("📥 Response body (partial): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      setState(() {
        searchResults = users;
        isLoading = false;
      });
      debugPrint("✅ Search results loaded: ${users.length} users found.");
    } else {
      setState(() {
        errorMessage = "Error ${response.statusCode}: ${response.reasonPhrase}";
        isLoading = false;
      });
      debugPrint("⚠️ Search failed: ${response.statusCode} - ${response.reasonPhrase}");
    }
  } catch (e) {
    setState(() {
      errorMessage = "Error: $e";
      isLoading = false;
    });
    debugPrint("💥 Exception during search: $e");
  }
}

  Future<void> toggleFollow(int userId, bool isFollowing) async {
    final token = await getAuthToken();

    if (token == null) {
      setState(() {
        errorMessage = "Login required to follow/unfollow.";
      });
      return;
    }

    final url = isFollowing
        ? "http://10.0.2.2:8000/user/unfollow/$userId/"
        : "http://10.0.2.2:8000/user/follow/$userId/";

    // Optimistically update UI before waiting for backend response
    setState(() {
      final index = searchResults.indexWhere((user) => user['id'] == userId);
      if (index != -1) {
        searchResults[index]['is_following'] = !isFollowing;
      }
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Rollback optimistic update if failed
        setState(() {
          final index = searchResults.indexWhere((user) => user['id'] == userId);
          if (index != -1) {
            searchResults[index]['is_following'] = isFollowing;
          }
          errorMessage = "Failed to follow/unfollow.";
        });
      }
    } catch (e) {
      // Rollback on error
      setState(() {
        final index = searchResults.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          searchResults[index]['is_following'] = isFollowing;
        }
        errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Users")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by username or full name',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (val) {
                query = val.trim();
                if (query.isNotEmpty) {
                  searchUsers(query);
                }
              },
            ),
          ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (searchResults.isEmpty)
            const Expanded(
              child: Center(child: Text("No users found.")),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  final fullName = (user['full_name'] ?? '').toString();
                  final username = (user['username'] ?? '').toString();
                  final photoUrlRaw = (user['photo_url'] ?? '').toString();
                  final isFollowing = user['is_following'] == true;
                  final isFollower = user['is_follower'] == true;
                  final userId = user['id'];

                  final photoUrl = photoUrlRaw.replaceFirst('192.168.18.7', '10.0.2.2');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        // Tappable profile section
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SearchUserProfilePage(
                                    userId: userId,
                                    isFollowing: isFollowing,
                                    isFollower: isFollower,
                                    onFollowChanged: (bool isNowFollowing) {
                                      setState(() {
                                        user['is_following'] = isNowFollowing;
                                         int followers = user['follower_count'] ?? 0;
                                        user['follower_count'] = isNowFollowing
                                            ? followers + 1
                                            : (followers > 0 ? followers - 1 : 0);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                                  child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName.isNotEmpty ? fullName : username,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('@$username', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Follow/Unfollow button
                        ElevatedButton(
                          onPressed: () {
                            toggleFollow(userId, isFollowing);
                          },
                          child: Text(  isFollowing ? "Unfollow" : (isFollower ? "Follow Back" : "Follow"),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.red.shade300 : Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
