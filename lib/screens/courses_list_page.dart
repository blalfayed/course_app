// ignore_for_file: use_build_context_synchronously, use_super_parameters

import 'package:course_app/screens/add_course_page.dart';
import 'package:course_app/screens/course_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/course_model.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({Key? key}) : super(key: key);

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCourses(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = _allCourses;
      });
    } else {
      setState(() {
        _filteredCourses = _allCourses
            .where((course) =>
                course.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

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
              height: 200,
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
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCoursePage(
                        course: course,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _deleteCourse(course.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQ = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses List'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCoursePage()),
              );
            },
            icon: const Icon(Icons.add),
          ),
          TextButton(
            onPressed: () {
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              _auth.signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('images/asd3.webp'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        color: Colors.cyan,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search courses...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) => _filterCourses(value),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No courses available'));
                  }

                  _allCourses = snapshot.data!.docs.map((doc) {
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

                  _filteredCourses = _searchController.text.isEmpty
                      ? _allCourses
                      : _allCourses
                          .where((course) => course.title
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .toList();

                  return GridView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 10,
                      childAspectRatio: .4,
                    ),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseDetailsPage(course: course),
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
          ],
        ),
      ),
    );
  }
}
