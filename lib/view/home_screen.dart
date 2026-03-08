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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAccountController.userRole(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userRole = snapshot.data ?? 'user';
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
            indexedStackChildren.add(const AdminScreen());
            bottomItems.add(
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
        return Scaffold(body: Center(child: CircularProgressIndicator(),));
      },
    );
  }
}
