import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Hồ sơ'),
      ),

      body: ListView(
        children: [
          const UserAvatar(),
          Center(child: const EditableUserDisplayName()),
          SignOutButton(
            auth: FirebaseAuth.instance,
          )
        ],
      ),
    );
  }
}