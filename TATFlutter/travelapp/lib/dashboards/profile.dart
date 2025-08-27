import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:travelapp/pages/login.dart';
import 'editprofile.dart';

import 'followlist.dart'; // 🔁 Make sure to create this page

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, loadProfile);
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final isManualLogin = prefs.getBool('isManualLoggedIn') ?? true;
    String? token;

    if (isManualLogin) {
      token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        await logout();
        return;
      }
    } else {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        await logout();
        return;
      }
      try {
        token = await firebaseUser.getIdToken(true);
        if (token?.isEmpty ?? true) {
          await logout();
          return;
        }
      } catch (e) {
        await logout();
        return;
      }
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/user/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        setState(() {
          isLoading = false;
          profileData = null;
        });
        return http.Response('{"error": "timeout"}', 408);
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } else if (response.statusCode == 401) {
      await logout();
    } else {
      setState(() {
        isLoading = false;
        profileData = null;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (mounted) Get.offAll(() => const Login());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileData == null) {
      return const Scaffold(
        body: Center(child: Text("You are not logged in.")),
      );
    }

    final profile = profileData!['profile'] ?? {};
    final posts = profileData!['posts'] ?? [];
    final fullName = (profile['full_name'] ?? '').toString().trim();
    final username = (profileData!['username'] ?? '').toString().trim();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(profileData: profileData),
                    ),
                  );
                  if (updated == true) await loadProfile();
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: (profile['photo_url'] != null &&
                          profile['photo_url'] != '')
                      ? ClipOval(
                          child: Image.network(
                            profile['photo_url']
                                .toString()
                                .replaceFirst('192.168.18.7', '10.0.2.2'),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 60, color: Colors.white);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fullName.isNotEmpty ? fullName : username,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (fullName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '@$username',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                profile['bio'] ?? 'No bio added yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

           Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (profileData != null) ...[
      GestureDetector(
        onTap: () {
          final userId = profileData?['id'];
          if (userId != null) {
            Get.to(() => FollowListPage(
                  userId: userId,
                  listType: FollowListType.followers,
                ));
           } else {
      // Optionally show a message or ignore tap
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data not loaded yet')),
      );
    }
  
        },
        child: _buildStat("Followers", profile['follower_count'] ?? 0),
      ),
      const SizedBox(width: 20),
      GestureDetector(
        onTap: () {
          final userId = profileData?['id'];
          if (userId != null) {
            Get.to(() => FollowListPage(
                  userId: userId,
                  listType: FollowListType.following,
                ));
          }
        },
        child: _buildStat("Following", profile['following_count'] ?? 0),
      ),
    ]
  ],
),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Your Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              posts.isEmpty
                  ? const Text("No posts yet.")
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final isPhoto = post['media_type'] == 'photo';
                        final mediaUrl = post['media_file'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            // TODO: Open full screen post view
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                mediaUrl.isNotEmpty
                                    ? Image.network(mediaUrl,
                                        fit: BoxFit.cover)
                                    : Container(
                                        color: Colors.grey.shade300),
                                if (!isPhoto)
                                  const Center(
                                    child: Icon(Icons.play_circle_outline,
                                        size: 40, color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, int? count) {
    return Column(
      children: [
        Text(
          count?.toString() ?? '0',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label),
      ],
    );
  }
}