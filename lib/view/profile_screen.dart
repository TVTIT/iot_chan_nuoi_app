import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Hồ sơ')),

      body: ListView(
        children: [
          const UserAvatar(),
          Center(child: const EditableUserDisplayName()),
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
    );
  }
}
