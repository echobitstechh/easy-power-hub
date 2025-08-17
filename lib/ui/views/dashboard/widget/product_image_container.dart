




import 'package:flutter/material.dart';

Widget buildImageContainer(String imagePath, double width, double height) {
  return Container(
    width: width,
    height: height,
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Image.network(imagePath, fit: BoxFit.cover),
  );
}