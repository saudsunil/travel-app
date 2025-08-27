
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';

// class EditProfilePage extends StatefulWidget {
//   final Map<String, dynamic>? profileData;

//   const EditProfilePage({Key? key, this.profileData}) : super(key: key);

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   late TextEditingController usernameController;
//   late TextEditingController fullNameController;
//   late TextEditingController bioController;

//   File? _pickedImageFile;
//   String? _photoUrl;
//   String? _gender;
//   DateTime? _selectedDOB;
//   bool isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     final data = widget.profileData ?? {};
//     final profile = data['profile'] ?? {};

//     usernameController = TextEditingController(text: data['username'] ?? '');
//     fullNameController = TextEditingController(text: profile['full_name'] ?? '');
//     bioController = TextEditingController(text: profile['bio'] ?? '');
//     _photoUrl = profile['photo_url'] ?? '';

//     // Sanitize gender input
//     final gender = profile['gender'];
//     if (gender == 'Male' || gender == 'Female' || gender == 'Other') {
//       _gender = gender;
//     } else {
//       _gender = null;
//     }

//     if (profile['dob'] != null && profile['dob'].toString().isNotEmpty) {
//       _selectedDOB = DateTime.tryParse(profile['dob']);
//     }
//   }

//   @override
//   void dispose() {
//     usernameController.dispose();
//     fullNameController.dispose();
//     bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
//     if (picked != null) {
//       setState(() => _pickedImageFile = File(picked.path));
//     }
//   }

//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDOB ?? DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: now,
//     );
//     if (picked != null) {
//       setState(() => _selectedDOB = picked);
//     }
//   }

//   Future<void> saveProfile() async {
//     setState(() => isSaving = true);

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       setState(() => isSaving = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User not logged in. Please log in again.')),
//       );
//       return;
//     }

//     final token = await user.getIdToken(true);
//     final uri = Uri.parse('http://192.168.18.7:8000/user/profile/');
//     final request = http.MultipartRequest('PUT', uri)
//       ..headers['Authorization'] = 'Bearer $token'
//       ..fields['username'] = usernameController.text.trim()
//       ..fields['full_name'] = fullNameController.text.trim()
//       ..fields['bio'] = bioController.text.trim()
//       ..fields['gender'] = _gender ?? ''
//       ..fields['dob'] = _selectedDOB != null
//           ? DateFormat('yyyy-MM-dd').format(_selectedDOB!)
//           : '';

//     debugPrint('📤 Sending data:');
//     request.fields.forEach((key, value) => debugPrint('$key: $value'));

//     if (_pickedImageFile != null) {
//       debugPrint('📸 Attaching image: ${_pickedImageFile!.path}');
//       request.files.add(await http.MultipartFile.fromPath('photo', _pickedImageFile!.path));
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//       setState(() => isSaving = false);

//       debugPrint('🔄 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final newPhotoUrl = data['profile']?['photo_url'];
//         setState(() => _photoUrl = newPhotoUrl);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//         Navigator.of(context).pop(true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update profile')),
//         );
//       }
//     } catch (e, stackTrace) {
//       setState(() => isSaving = false);
//       debugPrint('💥 Exception: $e');
//       debugPrint('🧵 StackTrace: $stackTrace');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Center(
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.grey.shade300,
//                     backgroundImage: _pickedImageFile != null
//                         ? FileImage(_pickedImageFile!)
//                         : (_photoUrl != null && _photoUrl!.isNotEmpty
//                             ? NetworkImage(_photoUrl!) as ImageProvider
//                             : null),
//                     child: (_pickedImageFile == null &&
//                             (_photoUrl == null || _photoUrl!.isEmpty))
//                         ? const Icon(Icons.person, size: 60, color: Colors.white)
//                         : null,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 4,
//                     child: ClipOval(
//                       child: Container(
//                         color: Colors.blue,
//                         child: IconButton(
//                           icon: const Icon(Icons.add, color: Colors.white),
//                           onPressed: _pickImage,
//                           tooltip: 'Change Photo',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             TextField(
//               controller: usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             const SizedBox(height: 12),

//             TextField(
//               controller: fullNameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             const SizedBox(height: 12),

//             InkWell(
//               onTap: _pickDate,
//               child: InputDecorator(
//                 decoration: const InputDecoration(labelText: 'DOB'),
//                 child: Text(
//                   _selectedDOB != null
//                       ? DateFormat('yyyy-MM-dd').format(_selectedDOB!)
//                       : 'Select your date of birth',
//                   style: const TextStyle(color: Colors.black),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             DropdownButtonFormField<String>(
//               value: ['Male', 'Female', 'Other'].contains(_gender) ? _gender : null,
//               items: const [
//                 DropdownMenuItem(value: 'Male', child: Text('Male')),
//                 DropdownMenuItem(value: 'Female', child: Text('Female')),
//                 DropdownMenuItem(value: 'Other', child: Text('Other')),
//               ],
//               onChanged: (value) => setState(() => _gender = value),
//               decoration: const InputDecoration(labelText: 'Gender'),
//             ),
//             const SizedBox(height: 12),

//             TextField(
//               controller: bioController,
//               decoration: const InputDecoration(labelText: 'Add Bio....'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 24),

//             ElevatedButton(
//               onPressed: isSaving ? null : saveProfile,
//               child: isSaving
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:travelapp/pages/crossauth.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const EditProfilePage({Key? key, this.profileData}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController fullNameController;
  late TextEditingController bioController;

  File? _pickedImageFile;
  String? _photoUrl;
  String? _gender;
  DateTime? _selectedDOB;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.profileData ?? {};
    final profile = data['profile'] ?? {};

    usernameController = TextEditingController(text: data['username'] ?? '');
    fullNameController = TextEditingController(text: profile['full_name'] ?? '');
    bioController = TextEditingController(text: profile['bio'] ?? '');
    _photoUrl = profile['photo_url'] ?? '';

    final gender = profile['gender']?.toString().toLowerCase();
    if (gender == 'male' || gender == 'female' || gender == 'other') {
      _gender = gender;
      debugPrint("🟢 Loaded gender: $_gender");
    } else {
      _gender = null;
      debugPrint("⚪ Gender not set or invalid");
    }

    if (profile['dob'] != null && profile['dob'].toString().isNotEmpty) {
      _selectedDOB = DateTime.tryParse(profile['dob']);
      debugPrint("🟢 Loaded DOB: $_selectedDOB");
    } else {
      debugPrint("⚪ DOB not set");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    debugPrint("📸 Opening image picker");
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      debugPrint("📸 Image selected: ${picked.path}");
      setState(() => _pickedImageFile = File(picked.path));
    } else {
      debugPrint("📸 Image picker canceled or no image selected");
    }
  }

  Future<void> _pickDate() async {
    debugPrint("📅 Opening date picker");
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700, // header bg color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      debugPrint("📅 Date selected: $picked");
      setState(() => _selectedDOB = picked);
    } else {
      debugPrint("📅 Date picker canceled");
    }
  }

  Future<void> saveProfile() async {
  debugPrint("💾 saveProfile() started");
  setState(() => isSaving = true);

  final token = await getAuthToken();
  debugPrint("🔑 Token: ${token?.substring(0,10)}...");

  if (token == null) {
    debugPrint("⚠️ Token null, abort saving");
    setState(() => isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login expired. Please log in again.')),
    );
    return;
  }

  final uri = Uri.parse('http://10.0.2.2:8000/user/profile/');
  final request = http.MultipartRequest('PUT', uri);
  request.headers['Authorization'] = 'Bearer $token';

  request.fields['username'] = usernameController.text.trim();
  request.fields['full_name'] = fullNameController.text.trim();
  request.fields['bio'] = bioController.text.trim();
  request.fields['gender'] = _gender ?? '';
  request.fields['dob'] = _selectedDOB != null
      ? DateFormat('yyyy-MM-dd').format(_selectedDOB!)
      : '';

  debugPrint("📤 Fields prepared:");
  request.fields.forEach((k, v) => debugPrint('   $k: $v'));

  if (_pickedImageFile != null) {
    debugPrint("📸 Attaching image: ${_pickedImageFile!.path}");
    try {
      final file = await http.MultipartFile.fromPath('photo', _pickedImageFile!.path);
      request.files.add(file);
    } catch (e) {
      debugPrint("⚠️ Error attaching image: $e");
    }
  }

  try {
    debugPrint("⏳ Sending request...");
    final streamedResponse = await request.send();
    debugPrint("⏳ Request sent, waiting response...");
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint("🔄 Response code: ${response.statusCode}");
    debugPrint("📥 Response body: ${response.body}");

    setState(() => isSaving = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newPhotoUrl = data['profile']?['photo_url'];
      setState(() => _photoUrl = newPhotoUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop(true);
    } else {
      debugPrint("❌ Failed to update profile");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  } catch (e, stackTrace) {
    debugPrint("💥 Exception during request: $e");
    debugPrint("🧵 StackTrace: $stackTrace");
    setState(() => isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating profile: $e')),
    );
  }
}


  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔧 Building EditProfilePage, isSaving=$isSaving');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : (_photoUrl != null && _photoUrl!.isNotEmpty
                                ? NetworkImage(_photoUrl!) as ImageProvider
                                : null),
                        child: (_pickedImageFile == null &&
                                (_photoUrl == null || _photoUrl!.isEmpty))
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: ClipOval(
                          child: Container(
                            color: Colors.green.shade700,
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: _pickImage,
                              tooltip: 'Change Photo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: usernameController,
                  decoration: inputDecoration('Username'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: fullNameController,
                  decoration: inputDecoration('Full Name'),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: inputDecoration('Date of Birth'),
                    child: Text(
                      _selectedDOB != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDOB!)
                          : 'Select your date of birth',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: ['male', 'female', 'other'].contains(_gender) ? _gender : null,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    debugPrint('⚙️ Gender changed to $value');
                    setState(() => _gender = value);
                  },
                  decoration: inputDecoration('Gender'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: bioController,
                  decoration: inputDecoration('Add Bio...'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: isSaving ? null : saveProfile,
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
