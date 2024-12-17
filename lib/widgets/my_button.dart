import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color colors;
  final String title;
  final dynamic onPressed;

  const MyButton(
      {super.key,
      required this.colors,
      required this.title,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        color: colors,
        borderRadius: BorderRadius.circular(15),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200,
          height: 42,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
