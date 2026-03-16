import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:iot_chan_nuoi_app/model/users_model.dart';

class EditUserScreen extends StatefulWidget {
  EditUserScreen({super.key, required this.user});

  final User user;

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  _EditUserScreenState();
  //late Map<dynamic, dynamic> _allNodesUserOwned;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  Future<void> _getAllNodesMapCache() async {
    if (FirebaseAccountController.allNodesMapCached.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAccountController.getAllNodesMap();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllNodesMapCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa người dùng')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      initialValue: widget.user.displayName,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên người dùng',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên không được bỏ trống';
                        }
                        return null;
                      },
                      onSaved: (newValue) =>
                          widget.user.displayName = newValue!,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Vai trò',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField(
                      items: FirebaseAccountController.userRolesMap.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ),
                          )
                          .toList(),
                      initialValue: widget.user.role,
                      onChanged: (_) {},
                      onSaved: (newValue) => widget.user.role = newValue!,
                    ),

                    SizedBox(height: 10),

                    const Text(
                      'ID người dùng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    TextFormField(
                      readOnly: true,
                      initialValue: widget.user.id,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.user.id),
                            );
                            const snackBar = SnackBar(
                              content: Text(
                                'Đã copy ID người dùng vào clipboard',
                              ),
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(snackBar);
                          },
                          icon: Icon(Icons.copy),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Node sở hữu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FormField<Map<dynamic, dynamic>>(
                      initialValue: widget.user.nodesOwned,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: FirebaseAccountController
                              .allNodesMapCached
                              .keys
                              .map(
                                (key) => CheckboxListTile(
                                  title: Text(
                                    FirebaseAccountController
                                        .allNodesMapCached[key]['name'],
                                  ),
                                  value: state.value![key] ?? false,
                                  onChanged: (value) {
                                    widget.user.nodesOwned[key] = value;
                                    state.didChange(widget.user.nodesOwned);
                                  },
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                    SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await FirebaseAccountController.setUserData(
                              widget.user,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: const Text(
                                  'Đã lưu thông tin người dùng',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {}
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const Text('Lưu lại'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
