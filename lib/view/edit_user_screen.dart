import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:iot_chan_nuoi_app/model/users_model.dart';

class EditUserScreen extends StatefulWidget {
  EditUserScreen({super.key, required this.user, required this.allNodesMap});

  final User user;
  Map<dynamic, dynamic> allNodesMap;

  @override
  State<EditUserScreen> createState() =>
      _EditUserScreenState(user: user, allNodesMap: allNodesMap);
}

class _EditUserScreenState extends State<EditUserScreen> {
  _EditUserScreenState({required this.user, required this.allNodesMap});

  final User user;
  Map<dynamic, dynamic> allNodesMap;
  //late Map<dynamic, dynamic> _allNodesUserOwned;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa người dùng')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                initialValue: user.displayName,
                decoration: InputDecoration(hintText: 'Nhập tên người dùng'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tên không được bỏ trống';
                  }
                  return null;
                },
                onSaved: (newValue) => user.displayName = newValue!,
              ),

              SizedBox(height: 10),

              Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField(
                items: FirebaseAccountController.userRolesMap.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                initialValue: user.role,
                onChanged: (_) {},
                onSaved: (newValue) => user.role = newValue!,
              ),

              SizedBox(height: 10),

              const Text(
                'ID người dùng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextFormField(
                readOnly: true,
                initialValue: user.id,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: user.id));
                      const snackBar = SnackBar(
                        content: Text('Đã copy ID người dùng vào clipboard'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    icon: Icon(Icons.copy),
                  ),
                ),
              ),

              SizedBox(height: 10),

              FormField<Map<dynamic, dynamic>>(
                initialValue: user.nodesOwned,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: allNodesMap.keys
                        .map(
                          (key) => CheckboxListTile(
                            title: Text(allNodesMap[key]['name']),
                            value: state.value![key] ?? false,
                            onChanged: (value) {
                              user.nodesOwned[key] = value;
                              state.didChange(user.nodesOwned);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    FirebaseDatabase.instance
                        .ref('users_list/${user.id}')
                        .set(user.toMap());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: const Text('Đã lưu thông tin người dùng'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Lưu lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
