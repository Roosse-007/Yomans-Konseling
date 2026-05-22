import 'package:flutter/material.dart';

Widget menuCard(String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 3,
      child: Center(
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
    ),
  );
}