// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:course_app/screens/courses_list_page_users.dart';
import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'cart_page.dart';

class MainPageUsers extends StatefulWidget {
  static String screenRoute = 'main_page_users';

  const MainPageUsers({super.key});

  @override
  State<MainPageUsers> createState() => _MainPageUsersState();
}

class _MainPageUsersState extends State<MainPageUsers> {
  int _selectedIndex = 0;

  static List<Widget> _pages = [
    const CoursesListPageUsers(),
    const FavoritesPage(),
    CartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Courses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
