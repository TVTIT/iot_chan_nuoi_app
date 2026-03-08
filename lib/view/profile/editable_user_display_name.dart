//Copy từ EditableUserDisplayName của FirebaseUI
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/src/widgets/internal/subtitle.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:iot_chan_nuoi_app/controller/firebase_account_controller.dart';

class MyEditableUserDisplayName extends StatefulWidget {
  const MyEditableUserDisplayName({super.key});

  @override
  State<MyEditableUserDisplayName> createState() =>
      _MyEditableUserDisplayNameState();
}

class _MyEditableUserDisplayNameState extends State<MyEditableUserDisplayName> {
  late TextEditingController ctrl;
  FirebaseAuth get auth => FirebaseAuth.instance;
  String? displayName;
  late bool _editing = displayName == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing(String newDisplayName) async {
    try {
      if (displayName == newDisplayName) return;

      setState(() {
        _isLoading = true;
      });

      //final previousDisplayName = displayName;
      displayName = newDisplayName;
      await FirebaseAccountController.setUserDisplayName(newDisplayName);

      // FirebaseUIAction.ofType<DisplayNameChangedAction>(
      //   context,
      // )?.callback(context, previousDisplayName, newDisplayName);
    } finally {
      setState(() {
        _editing = false;
        _isLoading = false;
      });
    }
  }

  Future<void> getUserDisplayName() async {
    String result = await FirebaseAccountController.userDisplayName();

    if (!mounted) {
      return;
    }

    setState(() {
      displayName = result;
      ctrl.text = result;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDisplayName();
    ctrl = TextEditingController();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (displayName == null) {
      return const LoadingIndicator(size: 24, borderWidth: 1);
    }

    Widget iconButton = IconButton(
      icon: Icon(_editing ? Icons.check : Icons.edit),
      color: theme.colorScheme.secondary,
      onPressed: _editing ? () => _finishEditing(ctrl.text) : _onEdit,
    );

    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Subtitle(text: displayName ?? 'Unknown'),
              iconButton,
            ],
          ),
        ),
      );
    }

    Widget textField = Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: const Text(
            'Tên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          autofocus: true,
          controller: ctrl,
          decoration: InputDecoration(hintText: 'Nhập tên của bạn'),
          onSubmitted: (_) => _finishEditing(ctrl.text),
        ),
      ],
    );

    return Row(
      children: [
        Expanded(child: textField),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 32,
          child: Stack(
            children: [
              if (_isLoading)
                const LoadingIndicator(size: 24, borderWidth: 1)
              else
                Align(alignment: Alignment.topLeft, child: iconButton),
            ],
          ),
        ),
      ],
    );
  }
}
