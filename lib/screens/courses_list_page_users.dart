// ignore_for_file: use_build_context_synchronously, unused_element, use_super_parameters

import 'package:course_app/screens/course_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CoursesListPageUsers extends StatefulWidget {
  const CoursesListPageUsers({Key? key}) : super(key: key);

  @override
  State<CoursesListPageUsers> createState() => _CoursesListPageUsersState();
}

class _CoursesListPageUsersState extends State<CoursesListPageUsers> {
  Future<void> _addToFavorites(Course course) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(course.id)
            .set({
          'title': course.title,
          'description': course.description,
          'photo': course.photo,
          'price': course.price,
          'videos': course.videos,
          'isFavorite': true,
          'isInCart': course.isInCart,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${course.title} added to Favorites'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to favorites: $e')),
        );
      }
    }
  }

  Future<void> _addToCart(Course course) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(course.id)
            .set({
          'title': course.title,
          'description': course.description,
          'photo': course.photo,
          'price': course.price,
          'videos': course.videos,
          'isFavorite': course.isFavorite,
          'isInCart': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${course.title} added to Cart'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting course: $e')),
      );
    }
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              course.photo ?? '',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${course.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  course.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: .1, // المسافة الأفقية بين العناصر
            runSpacing: 4.0, // المسافة الرأسية بين الصفوف
            children: [
              IconButton(
                icon:
                    const Icon(Icons.favorite_border, color: Colors.redAccent),
                onPressed: () => _addToFavorites(course),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.blueAccent),
                onPressed: () => _addToCart(course),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses List'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/asd3.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('courses').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No courses available'));
            }

            final courses = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Course(
                id: doc.id,
                title: data['title'] ?? 'No Title',
                description: data['description'] ?? 'No Description',
                photo: data['photo'] ?? '',
                videos: (data['videos'] is Iterable)
                    ? List<dynamic>.from(data['videos'])
                    : [],
                price: (data['price'] ?? 0).toDouble(),
                isFavorite: data['isFavorite'] ?? false,
                isInCart: data['isInCart'] ?? false,
              );
            }).toList();

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 10,
                childAspectRatio: 0.5,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(course: course),
                      ),
                    );
                  },
                  child: _buildCourseCard(course),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
