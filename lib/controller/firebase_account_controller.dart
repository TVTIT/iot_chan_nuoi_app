import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iot_chan_nuoi_app/model/users_model.dart' as UserModel;

class FirebaseAccountController {
  static const userRolesMap = {"user": "Người dùng", "admin": "Quản trị viên"};

  static Map<dynamic, dynamic> userDataCached = {};
  static Future<Map<dynamic, dynamic>> getCurrentUserData() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseEvent event = await FirebaseDatabase.instance
        .ref('users_list')
        .child(userId)
        .once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value != null) {
      userDataCached = snapshot.value as Map;
      return userDataCached;
    }
    return {};
  }

  static Future<void> setUserDisplayName(String newDisplayName) async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseDatabase.instance
        .ref('users_list')
        .child(userId)
        .child('display_name')
        .set(newDisplayName);
  }

  static Future<Map<dynamic, dynamic>> getAllNodesMap() async {
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref('farm_monitor')
        .once();
    final DataSnapshot snapshot = event.snapshot;

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

  static Future<List<String>> getUserNodesOwned() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref('users_list')
        .child(userId)
        .child('nodes_owned')
        .once();
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value != null) {
      try {
        final Map<dynamic, dynamic> nodesOwnedMap = snapshot.value as Map;
        return nodesOwnedMap.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key.toString())
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> setUserNodesOwned(
    Map<String, bool> nodesUserOwnedMap,
    String userId,
  ) async {
    await FirebaseDatabase.instance
        .ref('users_list/$userId/nodes_owned')
        .set(nodesUserOwnedMap);
  }

  static Future<void> setUserData(UserModel.User user) async {
    await FirebaseDatabase.instance
        .ref('users_list/${user.id}')
        .set(user.toMap());
  }

  //Đặt trong try catch khi dùng
  static Future<UserModel.User> createNewUserAsAdmin({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required Map<String, bool> nodesOwned,
  }) async {
    String newUserId = '';
    FirebaseApp? tempApp;
    try {
      //Tạo app phụ để tạo tài khoản mới
      tempApp = await Firebase.initializeApp(
        name: 'TemporaryApp', // Tên tùy ý
        options: Firebase.app().options, // Copy cấu hình của app chính
      );

      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(email: email, password: password);
      newUserId = userCredential.user!.uid;

      //Xoá app phụ
      await tempApp.delete();

      final newUserData = {
        "display_name": displayName,
        "nodes_owned": nodesOwned,
        "role": role,
      };

      await FirebaseDatabase.instance
          .ref('users_list/$newUserId')
          .set(newUserData);
    } on FirebaseAuthException {
      tempApp?.delete();
      rethrow;
    }
    return UserModel.User(
      id: newUserId,
      displayName: displayName,
      role: role,
      nodesOwned: nodesOwned,
    );
  }

  static String notificationTokenCached = "";
  static Future<void> getNotificationToken() async {
    notificationTokenCached = await FirebaseMessaging.instance.getToken() ?? "";
    print('Notification token: $notificationTokenCached');
  }

  static Future<void> updateUserDeviceToken() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final updateData = {notificationTokenCached: true};
    await FirebaseDatabase.instance
        .ref('users_list')
        .child(userId)
        .child('devices_list')
        .update(updateData);

    (userDataCached['devices_list'] ??= {})[notificationTokenCached] = true;
  }

  static Future<void> removeUserDeviceToken() async {
    if (notificationTokenCached == "") {
      return;
    }
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseDatabase.instance
          .ref('users_list')
          .child(userId)
          .child('devices_list')
          .child(notificationTokenCached)
          .remove();
    } catch (e) {}
  }
}
