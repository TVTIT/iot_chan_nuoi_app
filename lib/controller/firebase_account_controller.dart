import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseAccountController {
  static const userRolesMap = {"user": "Người dùng", "admin": "Quản trị viên"};

  static String userRoleCached = '';
  static Future<String> userRole() async {
    final String userUID = FirebaseAuth.instance.currentUser!.uid;
    final DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('users_list/$userUID/role')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      userRoleCached = snapshot.value.toString();
      return userRoleCached;
    }
    return '';
  }

  static String userDisplayNameCached = '';
  static Future<String> userDisplayName() async {
    final String userUID = FirebaseAuth.instance.currentUser!.uid;
    final DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('users_list/$userUID/display_name')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      userDisplayNameCached = snapshot.value.toString();
      return userDisplayNameCached;
    }
    return '';
  }

  static Future<void> setUserDisplayName(String newDisplayName) async {
    final String userUID = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseDatabase.instance
        .ref('users_list/$userUID/display_name')
        .set(newDisplayName);
  }

  static Future<Map<dynamic, dynamic>> getAllNodesMap() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('farm_monitor')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      try {
        final Map<dynamic, dynamic> allNodeMap = snapshot.value as Map;
        return allNodeMap;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<Map<dynamic, dynamic>> getAllNodesUserOwnedMap(
    String userId,
  ) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref('users_list/$userId/nodes_owned')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      try {
        final Map<dynamic, dynamic> userOwnedNodesMap = snapshot.value as Map;
        return userOwnedNodesMap;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> setUserNodesOwned(
    Map<String, bool> nodesUserOwnedMap,
    String userId,
  ) async {
    await FirebaseDatabase.instance
        .ref('users_list/$userId/nodes_owned')
        .set(nodesUserOwnedMap);
  }
}
