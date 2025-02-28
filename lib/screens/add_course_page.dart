// ignore_for_file: sort_child_properties_last, prefer_final_fields, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/course_model.dart';
import '../services/cloudinary_service.dart';

class AddCoursePage extends StatefulWidget {
  final Course? course;

  const AddCoursePage({super.key, this.course});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _photoUrl;
  bool _isFavorite = false;
  bool _isInCart = false;
  bool _isLoading = false;

  List<String> _videoUrls = [];

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
        });

        final file = File(pickedFile.path);
        final uploadedUrl = await CloudinaryService.uploadFile(file);

        setState(() {
          _photoUrl = uploadedUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading photo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    double? price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (_photoUrl == null || _videoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please upload a photo and add at least one video URL')),
      );
      return;
    }

    try {
      final course = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': price,
        'photo': _photoUrl,
        'videos': _videoUrls,
        'isFavorite': _isFavorite,
        'isInCart': _isInCart,
      };

      await FirebaseFirestore.instance.collection('courses').add(course);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding course: $e')),
      );
    }
  }

  void _addVideoField() {
    setState(() {
      _videoUrls.add('');
    });
  }

  void _removeVideoField(int index) {
    setState(() {
      _videoUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Course'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Course Title',
                      icon: Icons.title,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Course Description',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Course Price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: _pickAndUploadPhoto,
                      icon: const Icon(Icons.photo),
                      label: const Text('Upload Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    if (_photoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Photo Uploaded: $_photoUrl',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Video URLs:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _videoUrls.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _videoUrls[index],
                                decoration: InputDecoration(
                                  labelText: 'Video URL ${index + 1}',
                                  prefixIcon: const Icon(Icons.video_library),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _videoUrls[index] = value;
                                },
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a video URL'
                                    : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeVideoField(index),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addVideoField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _addCourse,
                        child: const Text('Add Course'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 50.0),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
