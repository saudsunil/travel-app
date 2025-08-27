import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:travelapp/pages/crossauth.dart';
import 'searchuserprofile.dart';

enum FollowListType { followers, following }

class FollowListPage extends StatefulWidget {
  final int userId;
  final FollowListType listType;

  const FollowListPage({
    super.key,
    required this.userId,
    required this.listType,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFollowList();
  }

  Future<void> fetchFollowList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await getAuthToken();
    if (token == null) {
      setState(() {
        errorMessage = "Not logged in.";
        isLoading = false;
      });
      return;
    }

    final endpoint = widget.listType == FollowListType.followers ? 'followers' : 'following';
    final url = 'http://10.0.2.2:8000/user/$endpoint/${widget.userId}/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load $endpoint (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.listType == FollowListType.followers ? "Followers" : "Following";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : users.isEmpty
                  ? Center(child: Text("No $title found."))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final username = user['username']?.toString() ?? 'User';
                        final imageUrl = user['profile_image']?.toString() ?? '';
                        final userId = user['id'];

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            child: imageUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      imageUrl.replaceFirst('192.168.18.7', '10.0.2.2'),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.person, color: Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(username),
                          onTap: () {
                            if (userId != null && userId is int) {
                              Get.to(() => SearchUserProfilePage(userId: userId));
                            } else {
                              debugPrint("❌ Invalid or missing user ID in user: $user");
                              Get.snackbar("Error", "Invalid user profile data",
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          },
                        );
                      },
                    ),
    );
  }
}
