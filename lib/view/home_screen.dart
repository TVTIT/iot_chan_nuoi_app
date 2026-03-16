import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:iot_chan_nuoi_app/view/admin/admin_screen.dart';
import 'list_nodes_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //lưu vị trí các tab
  int _currentIndex = 0;
  late Future<Map<dynamic, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseAccountController.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final userDataMap = snapshot.data as Map;

          if (Platform.isAndroid ||
              FirebaseAccountController.notificationTokenCached.isNotEmpty) {
            final userDevices = userDataMap['devices_list'] ?? {};
            final bool isDeviceOnList =
                userDevices[FirebaseAccountController
                    .notificationTokenCached] ??
                false;

            if (!isDeviceOnList) {
              FirebaseAccountController.updateUserDeviceToken();
            }
          }

          final userRole = userDataMap['role'] ?? 'user';
          List<Widget> indexedStackChildren = [
            const ListNodesScreen(),
            const MyProfileScreen(),
          ];
          List<BottomNavigationBarItem> bottomItems = [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ];
          if (userRole == 'admin') {
            indexedStackChildren.insert(1, const AdminScreen());
            bottomItems.insert(
              1,
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Quản lý',
              ),
            );
          }
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: indexedStackChildren,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,

              items: bottomItems,
            ),
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
