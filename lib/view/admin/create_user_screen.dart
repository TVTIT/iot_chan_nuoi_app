import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';
import 'package:iot_chan_nuoi_app/model/users_model.dart' as UserModel;

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isCreatingUser = false;
  String? _emailErrorText;

  late Future<Map<dynamic, dynamic>> _nodesFuture;

  String _displayName = '';
  String _email = '';
  String _password = '';
  String _role = '';
  Map<String, bool> _nodesOwned = {};

  @override
  void initState() {
    super.initState();
    _nodesFuture = FirebaseAccountController.getAllNodesMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo người dùng mới')),

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder(
          future: _nodesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tên người dùng',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên không được bỏ trống';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _displayName = newValue!,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nhập email',
                        errorText: _emailErrorText,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được bỏ trống';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (_emailErrorText != null) {
                          setState(() {
                            _emailErrorText = null;
                          });
                        }
                      },
                      onSaved: (newValue) => _email = newValue!,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Mật khẩu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                          icon: _obscurePassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mật khẩu không được bỏ trống';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _password = newValue!,
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
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      initialValue: 'user',
                      onChanged: (_) {},
                      onSaved: (newValue) => _role = newValue!,
                    ),

                    SizedBox(height: 10),

                    FormField<Map<dynamic, dynamic>>(
                      initialValue: _nodesOwned,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!.keys
                              .map(
                                (key) => CheckboxListTile(
                                  title: Text(snapshot.data![key]['name']),
                                  value: _nodesOwned[key] ?? false,
                                  onChanged: (value) {
                                    final currentNodesOwned =
                                        Map<String, bool>.from(_nodesOwned);
                                    currentNodesOwned[key] = value ?? false;
                                    setState(() {
                                      _nodesOwned = currentNodesOwned;
                                    });
                                    state.didChange(_nodesOwned);
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
                          setState(() {
                            _isCreatingUser = true;
                          });
                          _formKey.currentState!.save();
                          try {
                            UserModel.User newUser =
                                await FirebaseAccountController.createNewUserAsAdmin(
                                  email: _email,
                                  password: _password,
                                  displayName: _displayName,
                                  role: _role,
                                  nodesOwned: _nodesOwned,
                                );
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Tạo tài khoản thành công',
                                    ),
                                    content: SelectableText.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Đã tạo tài khoản thành công với thông tin sau:\n',
                                          ),
                                          TextSpan(
                                            text: 'Tên người dùng: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: '$_displayName\n'),
                                          TextSpan(
                                            text: 'Email: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: '$_email\n'),
                                          TextSpan(
                                            text: 'Mật khẩu: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: '$_password\n'),
                                          TextSpan(
                                            text: 'Vai trò: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                FirebaseAccountController
                                                    .userRolesMap[_role] ??
                                                'Người dùng',
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Clipboard.setData(
                                          ClipboardData(text: _email),
                                        ),
                                        child: Text('Copy email'),
                                      ),
                                      TextButton(
                                        onPressed: () => Clipboard.setData(
                                          ClipboardData(text: _password),
                                        ),
                                        child: Text('Copy mật khẩu'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              setState(() {
                                _emailErrorText = 'Email này đã được sử dụng';
                              });
                            }
                          }
                          setState(() {
                            _isCreatingUser = false;
                          });
                          //Navigator.pop(context);
                        }
                      },
                      child: _isCreatingUser
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Text('Lưu lại'),
                    ),
                  ],
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
