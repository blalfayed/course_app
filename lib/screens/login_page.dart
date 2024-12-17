// ignore_for_file: use_key_in_widget_constructors, unnecessary_null_comparison, use_build_context_synchronously, avoid_print

import 'package:course_app/screens/main_page_users.dart';
import 'package:course_app/screens/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/my_button.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  static String screenRoute = 'login_page';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title:
            const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange[800],
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/asd.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // حقل البريد الإلكتروني
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.orange),
                      hintText: 'Enter your Email',
                      filled: true,
                      fillColor: Colors.cyan,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  // حقل كلمة المرور
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                      hintText: 'Enter your Password',
                      filled: true,
                      fillColor: Colors.cyan,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                  const SizedBox(height: 30),
                  // زر تسجيل الدخول
                  MyButton(
                    colors: Colors.orange[800]!,
                    title: 'Sign In',
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        if (email == "fayedblal@yahoo.com") {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          if (user != null) {
                            Navigator.pushNamed(context, MainPage.screenRoute);
                          }
                        } else {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          if (user != null) {
                            Navigator.pushNamed(
                                context, MainPageUsers.screenRoute);
                          }
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // زر التسجيل
                  MyButton(
                    colors: const Color.fromARGB(255, 173, 157, 15),
                    title: 'Register',
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RegistrationPage.screenRoute);
                    },
                  ),
                  const SizedBox(height: 20),
                  // نص للتوجيه
                  const Text(
                    'Don\'t have an account? Register now!',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
