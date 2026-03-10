import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:iot_chan_nuoi_app/model/users_model.dart';
import 'package:iot_chan_nuoi_app/view/admin/create_user_screen.dart';
import 'package:iot_chan_nuoi_app/view/admin/edit_user_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref(
    'users_list',
  );

  late Map<dynamic, dynamic> _allNodesMap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDataRequired();
  }

  Future<void> _getDataRequired() async {
    setState(() {
      _isLoading = true;
    });
    _allNodesMap = await FirebaseAccountController.getAllNodesMap();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Danh sách người dùng'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => CreateUserScreen()),
        ),
        shape: const CircleBorder(),
        child: Icon(Icons.add),
      ),

      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : StreamBuilder(
              stream: databaseRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final rawData =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<User> listUsers = [];
                  rawData.forEach((key, value) {
                    final user = User.fromEntry(key.toString(), value as Map);
                    listUsers.add(user);
                  });
                  return ListView.builder(
                    itemCount: listUsers.length,
                    itemBuilder: (context, index) {
                      final user = listUsers[index];
                      int nodesOwnedNum = user.nodesOwned.entries
                          .where((entry) => entry.value == true)
                          .length;
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            "Tên: ${user.displayName}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vai trò: ${FirebaseAccountController.userRolesMap[user.role] ?? 'Người dùng'}",
                              ),
                              Text("Sở hữu: $nodesOwnedNum node"),
                              Text(
                                "ID người dùng: ${user.id.substring(0, 10)}...",
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => EditUserScreen(
                                user: user,
                                allNodesMap: _allNodesMap,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: const CircularProgressIndicator());
              },
            ),
    );
  }
}
