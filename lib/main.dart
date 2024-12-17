import 'package:course_app/screens/login_page.dart';
import 'package:course_app/screens/main_page_users.dart';
import 'package:course_app/screens/video_player_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/main_page.dart';
import 'screens/registration_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CoursesApp());
}

class CoursesApp extends StatelessWidget {
  const CoursesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courses Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        RegistrationPage.screenRoute: (context) => RegistrationPage(),
        MainPage.screenRoute: (context) => const MainPage(),
        MainPageUsers.screenRoute: (context) => const MainPageUsers(),
        VideoPlayerPage.screenRoute: (context) {
          final courseId = ModalRoute.of(context)!.settings.arguments as String;
          return VideoPlayerPage(courseId: courseId);
        },
      },
    );
  }
}
