import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userUID = FirebaseAuth.instance.currentUser!.uid;
    final String userEmail = FirebaseAuth.instance.currentUser!.email!;
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Hồ sơ')),

      body: Container(
        margin: EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const UserAvatar(),
            Center(child: const EditableUserDisplayName()),

            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),

            TextFormField(readOnly: true, initialValue: userEmail),

            SizedBox(height: 10),

            const Text(
              'Vai trò',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            FutureBuilder<String>(
              future: FirebaseAccountController.userRole(),
              builder: (context, snapshot) {
                return TextFormField(
                  readOnly: true,
                  initialValue: snapshot.data! == 'admin' ? 'Quản trị viên': 'Người dùng',
                );
              },
            ),

            SizedBox(height: 10),

            const Text(
              'ID người dùng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            TextFormField(
              readOnly: true,
              initialValue: userUID,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: userUID));
                    const snackBar = SnackBar(
                      content: Text('Đã copy ID người dùng vào clipboard'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: Icon(Icons.copy),
                ),
              ),
            ),

            SizedBox(height: 40),

            SignOutButton(auth: FirebaseAuth.instance),

            SizedBox(height: 80),

            //dùng FutureBuilder để đợi có thông tin thì mới in được
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final packageInfo = snapshot.data!;
                  return Center(
                    child: Text(
                      'IOT chăn nuôi version ${packageInfo.version} build ${packageInfo.buildNumber}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                //return rỗng khi chưa có data
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
