import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAccountController {
  static String userRoleCached = '';
  static Future<String> userRole() async {
    final String userUID = FirebaseAuth.instance.currentUser!.uid;
    final DataSnapshot snapshot = await FirebaseDatabase.instance.ref('users_list/$userUID/role').get();

    if (snapshot.exists && snapshot.value != null) {
      userRoleCached = snapshot.value.toString();
      return userRoleCached;
    }
    return '';
  }
}