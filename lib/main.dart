import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oh_tp/models/firebase/user_role.dart';
import 'package:oh_tp/models/user_role.dart';

import 'package:oh_tp/pages/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.instance.registerSingleton<UserRoleModel>(FirebaseUserRoleModel());

  runPreLaunchTasks();

  runApp(const App());
}

void runPreLaunchTasks() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    // sign in anonymously
    await auth.signInAnonymously();
  }
  debugPrint("signed in as ${auth.currentUser?.uid}");

  GetIt.instance<UserRoleModel>().initialise();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(),
      home: const HomePage(),
    );
  }
}

ThemeData buildTheme() {
  final theme = ThemeData.dark(useMaterial3: true);

  return theme.copyWith(
    textTheme: GoogleFonts.interTightTextTheme(theme.textTheme),
  );
}
