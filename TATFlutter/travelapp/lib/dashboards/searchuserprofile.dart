import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/crossauth.dart';
// import 'package:travelapp/dashboards/searchuserprofile.dart';


class SearchUserProfilePage extends StatefulWidget {
  final int userId;
  final bool? isFollowing;
  final bool? isFollower;
  final void Function(bool isNowFollowing)? onFollowChanged;

  const SearchUserProfilePage({
    super.key,
    required this.userId,
    this.isFollowing,
    this.isFollower,
    this.onFollowChanged,
  });

  @override
  State<SearchUserProfilePage> createState() => _SearchUserProfilePageState();
}

class _SearchUserProfilePageState extends State<SearchUserProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await getAuthToken();
    debugPrint("🔑 Token: ${token?.substring(0, 20)}...");

    if (token == null) {
      setState(() {
        errorMessage = "User not logged in.";
        isLoading = false;
      });
      return;
    }

    final url = 'http://10.0.2.2:8000/user/profile/${widget.userId}/';
    debugPrint("🌐 GET: $url");

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("📥 Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load profile. Status: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("💥 Exception: $e");
      setState(() {
        errorMessage = "Error fetching profile: $e";
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    final token = await getAuthToken();
    if (token == null || userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    final int userId = widget.userId;
    final bool isFollowing = userData!['is_following'] ?? false;
    final url = isFollowing
        ? 'http://10.0.2.2:8000/user/unfollow/$userId/'
        : 'http://10.0.2.2:8000/user/follow/$userId/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          final newFollowState = !isFollowing;
          userData!['is_following'] = newFollowState;

          final followerCount = userData!['follower_count'] ?? 0;
          userData!['follower_count'] = newFollowState
              ? (followerCount + 1)
              : (followerCount > 0 ? followerCount - 1 : 0);
        });

        widget.onFollowChanged?.call(userData!['is_following']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to follow/unfollow.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred during follow/unfollow.")),
      );
    }
  }

  String getFollowLabel() {
    final isFollowing = userData?['is_following'] ?? false;
    final isFollower = userData?['is_follower'] ?? false;

    if (isFollowing) return 'Unfollow';
    if (isFollower) return 'Follow Back';
    return 'Follow';
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(
          child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("User not found.")),
      );
    }

    final String username = userData?['username'] ?? '';
    final String fullName = userData?['full_name'] ?? '';
    final int followers = userData?['follower_count'] ?? 0;
    final int following = userData?['following_count'] ?? 0;

    final String rawPhoto = userData?['photo_url'] ?? '';
    final bool hasPhoto = rawPhoto.isNotEmpty;
    final String photoUrl = hasPhoto
        ? (rawPhoto.startsWith('http')
            ? rawPhoto.replaceFirst('192.168.18.7', '10.0.2.2')
            : 'http://10.0.2.2:8000$rawPhoto')
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: RefreshIndicator(
        onRefresh: fetchUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                child: hasPhoto
                    ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Show default icon on image load error
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                fullName.isNotEmpty ? fullName : username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (fullName.isNotEmpty)
                Text('@$username', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStat("Followers", followers),
                  const SizedBox(width: 20),
                  _buildStat("Following", following),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (userData?['is_following'] ?? false)
                      ? Colors.red.shade300
                      : Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(getFollowLabel()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
