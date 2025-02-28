// ignore_for_file: library_private_types_in_public_api, use_super_parameters, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import 'course_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // دالة لجلب بيانات المفضلة من Firestore
  Stream<List<Course>> _getFavorites() {
    if (_currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('favorites')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                return Course(
                  id: doc.id,
                  title: data['title'] ?? 'No Title',
                  description: data['description'] ?? 'No Description',
                  price: (data['price'] ?? 0).toDouble(),
                  photo: data['photo'] ?? '',
                  videos: (data['videos'] is Iterable)
                      ? List<dynamic>.from(data['videos'])
                      : [],
                  isFavorite: true,
                  isInCart: data['isInCart'] ?? false,
                );
              }).toList());
    } else {
      return const Stream.empty();
    }
  }

  // دالة لحذف كورس من المفضلة
  Future<void> _removeFromFavorites(String courseId) async {
    try {
      if (_currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('favorites')
            .doc(courseId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course removed from favorites')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing course: $e')),
      );
    }
  }

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _currentUser == null
          ? const Center(
              child: Text(
                'Please log in to view favorites.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/asd4.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: StreamBuilder<List<Course>>(
                stream: _getFavorites(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Error loading favorites: ${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold),
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorite courses yet.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  final favorites = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      var course = favorites[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 5.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: course.photo.isNotEmpty
                                ? Image.network(
                                    course.photo,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 60),
                          ),
                          title: Text(
                            course.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            course.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _removeFromFavorites(course.id.toString()),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailsPage(course: course),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
