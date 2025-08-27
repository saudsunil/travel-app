

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../pages/crossauth.dart';
// import 'searchuserprofile.dart';

// // ... imports remain the same

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   List<dynamic> notifications = [];
//   bool isLoading = true;
//   String? errorMessage;
//   Map<int, Map<String, bool>> followMap = {}; // 🟢 senderId => {'is_following': true/false, 'is_follower': true/false}

//   @override
//   void initState() {
//     super.initState();
//     fetchNotifications();
//   }

//   Future<void> fetchNotifications() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     final token = await getAuthToken();
//     if (token == null) {
//       setState(() {
//         errorMessage = 'You must be logged in to view notifications.';
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.18.7:8000/user/notifications/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         setState(() {
//           notifications = data;
//           followMap.clear();

//           for (var notif in data) {
//             final senderId = notif['sender'];
//             followMap[senderId] = {
//               'is_following': notif['is_following'] ?? false,
//               'is_follower': notif['is_follower'] ?? false,
//             };
//           }

//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load notifications.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching notifications: $e';
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> toggleFollow(int userId) async {
//     final token = await getAuthToken();
//     if (token == null) return;

//     final current = followMap[userId] ?? {'is_following': false, 'is_follower': false};
//     final isFollowing = current['is_following']!;

//     final url = isFollowing
//         ? 'http://192.168.18.7:8000/user/unfollow/$userId/'
//         : 'http://192.168.18.7:8000/user/follow/$userId/';

//     setState(() {
//       followMap[userId]?['is_following'] = !isFollowing;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode != 200 && response.statusCode != 201) {
//         setState(() {
//           followMap[userId]?['is_following'] = isFollowing;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         followMap[userId]?['is_following'] = isFollowing;
//       });
//     }
//   }

//   String getFollowLabel(bool isFollowing, bool isFollower) {
//     if (isFollowing) return 'Unfollow';
//     if (isFollower) return 'Follow Back';
//     return 'Follow';
//   }

//   String getShortTime(String timestamp) {
//     try {
//       final dt = DateTime.parse(timestamp).toLocal();
//       final now = DateTime.now();
//       final diff = now.difference(dt);

//       if (diff.inSeconds < 60) return '${diff.inSeconds}s';
//       if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//       if (diff.inHours < 24) return '${diff.inHours}h';
//       if (diff.inDays < 7) return '${diff.inDays}d';
//       if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
//       if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
//       return '${(diff.inDays / 365).floor()}y';
//     } catch (_) {
//       return '';
//     }
//   }

//   String fixPhotoUrl(String rawUrl) {
//     if (rawUrl.isEmpty) return '';
//     return rawUrl.replaceFirst('192.168.18.7', '10.0.2.2');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(child: Text(errorMessage!))
//               : notifications.isEmpty
//                   ? const Center(child: Text('No notifications'))
//                   : ListView.builder(
//                       itemCount: notifications.length,
//                       itemBuilder: (context, index) {
//                         final notif = notifications[index];
//                         final senderId = notif['sender'];
//                         final username = notif['sender_username'] ?? '';
//                         final timestamp = notif['timestamp'] ?? '';
//                         final notificationType = notif['notification_type'] ?? '';
//                         final rawPhotoUrl = notif['sender_photo_url'] ?? '';
//                         final photoUrl = fixPhotoUrl(rawPhotoUrl);

//                         final followData = followMap[senderId] ?? {'is_following': false, 'is_follower': false};
//                         final isFollowing = followData['is_following']!;
//                         final isFollower = followData['is_follower']!;
//                         final buttonLabel = getFollowLabel(isFollowing, isFollower);

//                         return Card(
//                           color: Colors.green.shade50,
//                           margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                           child: ListTile(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => SearchUserProfilePage(
//                                     userId: senderId,
//                                     isFollowing: isFollowing,
//                                     isFollower: isFollower,
//                                     onFollowChanged: (nowFollowing) {
//                                       setState(() {
//                                         followMap[senderId]?['is_following'] = nowFollowing;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                             leading: CircleAvatar(
//                               backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
//                               child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
//                             ),
//                             title: Text('$username $notificationType you'),
//                             subtitle: Text(getShortTime(timestamp)),
//                             trailing: notificationType == 'follow'
//                                 ? ElevatedButton(
//                                     onPressed: () => toggleFollow(senderId),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: isFollowing ? Colors.red : Colors.green.shade700,
//                                     ),
//                                     child: Text(buttonLabel),
//                                   )
//                                 : null,
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/crossauth.dart';
import 'searchuserprofile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? errorMessage;
  Map<int, Map<String, bool>> followMap = {};

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await getAuthToken();
    if (token == null) {
      setState(() {
        errorMessage = 'You must be logged in to view notifications.';
        isLoading = false;
      });
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

        // Deduplication logic: group by sender, keep most relevant
        final Map<int, Map<String, dynamic>> latestPerSender = {};
        final List<Map<String, dynamic>> uniqueNotifications = [];

        for (var item in data) {
          final notif = Map<String, dynamic>.from(item);
          final senderId = notif['sender'];
          final msg = notif['message'] ?? '';

          if (!latestPerSender.containsKey(senderId)) {
            latestPerSender[senderId] = notif;
          } else {
            final current = latestPerSender[senderId]!;
            final existingMsg = current['message'] ?? '';

            // Prefer "followed you back"
            if (msg.contains("followed you back")) {
              latestPerSender[senderId] = notif;
            } else if (!existingMsg.contains("followed you back")) {
              // Overwrite if existing is not "followed you back"
              latestPerSender[senderId] = notif;
            }
          }
        }

        uniqueNotifications.addAll(latestPerSender.values);

        setState(() {
          notifications = uniqueNotifications;
          followMap.clear();
          for (var notif in notifications) {
            final senderId = notif['sender'];
            followMap[senderId] = {
              'is_following': notif['is_following'] ?? false,
              'is_follower': notif['is_follower'] ?? false,
            };
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load notifications (${response.statusCode}).';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching notifications: $e';
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow(int userId) async {
    final token = await getAuthToken();
    if (token == null) return;

    final current = followMap[userId] ?? {'is_following': false, 'is_follower': false};
    final isFollowing = current['is_following']!;

    final url = isFollowing
        ? 'http://10.0.2.2:8000/user/unfollow/$userId/'
        : 'http://10.0.2.2:8000/user/follow/$userId/';

    setState(() {
      followMap[userId]?['is_following'] = !isFollowing;
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
        setState(() {
          followMap[userId]?['is_following'] = isFollowing;
        });
      }
    } catch (e) {
      setState(() {
        followMap[userId]?['is_following'] = isFollowing;
      });
    }
  }

  String getFollowLabel(bool isFollowing, bool isFollower) {
    if (isFollowing) return 'Unfollow';
    if (isFollower) return 'Follow Back';
    return 'Follow';
  }

  String getShortTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return '';
    }
  }

  String fixPhotoUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    return rawUrl.replaceFirst('192.168.18.7', '10.0.2.2');
  }

  Future<void> markAllAsRead() async {
    final token = await getAuthToken();
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/notifications/mark-all-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          notifications = notifications.map((notif) {
            notif['is_read'] = true;
            return notif;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark all as read.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade600,
            child: TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark All as Read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : notifications.isEmpty
                        ? const Center(child: Text('No notifications found.'))
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              final senderId = notif['sender'];
                              final username = notif['sender_username'] ?? 'Unknown';
                              final timestamp = notif['timestamp'] ?? '';
                              final message = notif['message'] ?? '';
                              final rawPhotoUrl = notif['sender_photo_url'] ?? '';
                              final photoUrl = fixPhotoUrl(rawPhotoUrl);
                              final isRead = notif['is_read'] ?? false;

                              final followData = followMap[senderId] ?? {
                                'is_following': false,
                                'is_follower': false
                              };
                              final isFollowing = followData['is_following']!;
                              final isFollower = followData['is_follower']!;
                              final buttonLabel = getFollowLabel(isFollowing, isFollower);

                              return Card(
                                color: isRead ? Colors.grey[100] : Colors.green[50],
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                                    child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(username),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message),
                                      const SizedBox(height: 4),
                                      Text(
                                        getShortTime(timestamp),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => toggleFollow(senderId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFollowing ? Colors.red.shade300 : Colors.green,
                                      minimumSize: const Size(90, 36),
                                    ),
                                    child: Text(buttonLabel, style: const TextStyle(color: Colors.white)),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SearchUserProfilePage(
                                          userId: senderId,
                                          isFollowing: isFollowing,
                                          isFollower: isFollower,
                                          onFollowChanged: (nowFollowing) {
                                            setState(() {
                                              followMap[senderId]?['is_following'] = nowFollowing;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
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
