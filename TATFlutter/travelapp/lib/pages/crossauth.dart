import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  final method = prefs.getString('auth_method');

  if (method == 'firebase') {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      // `true` forces token refresh; omit if you want cached token
      final idToken = await user.getIdToken(true);
      return idToken;
    } catch (e) {
      print('Error getting Firebase ID token: $e');
      return null;
    }
  } else if (method == 'jwt') {
    return prefs.getString('auth_token');
  }
  return null;
}
