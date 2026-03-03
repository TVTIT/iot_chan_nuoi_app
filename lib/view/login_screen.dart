import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  //Dịch các lỗi firebase trả về khi đăng nhập
  static void localizeError() {
    ErrorText.localizeError = (BuildContext context, FirebaseAuthException e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Tài khoản hoặc mật khẩu không chính xác.';
        case 'user-not-found':
          return 'Email này chưa được đăng ký.';
        case 'wrong-password':
          return 'Mật khẩu không đúng.';
        case 'user-disabled':
          return 'Tài khoản này đã bị khóa.';
        case 'too-many-requests':
          return 'Bạn đã nhập sai quá nhiều lần. Vui lòng thử lại sau ít phút.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra Wifi/4G.';
        default:
          final defaultLabels = FirebaseUILocalizations.labelsOf(context);
          return localizedErrorText(e.code, defaultLabels) ?? 'Đã có lỗi xảy ra (${e.code})';
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/sanslab_logo.png'),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/sanslab_logo.png'),
                ),
              );
            },
            showPasswordVisibilityToggle: true,
            showAuthActionSwitch: false,
          );
        }

        return const HomeScreen();
      },
    );
  }
}
