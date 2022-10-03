import 'package:docsgoogle/constants/colors.dart';
import 'package:docsgoogle/repository/auth_repository.dart';
import 'package:docsgoogle/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).singInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace("/");
    } else {
      sMessenger
          .showSnackBar(SnackBar(content: Text(errorModel.error ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: kColorsWhite, minimumSize: const Size(150, 50)),
          onPressed: () {
            signInWithGoogle(ref, context);
          },
          icon: Image.asset(
            "assets/g-logo-2.png",
            height: 30,
          ),
          label: const Text(
            "Sign with google",
            style: TextStyle(
              color: kColorsBlack,
            ),
          ),
        ),
      ),
    );
  }
}
