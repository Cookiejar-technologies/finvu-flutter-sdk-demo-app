import 'package:flutter/material.dart';

class SharedStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle infoTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle statusStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const EdgeInsets containerPadding = EdgeInsets.all(20);
  static const EdgeInsets sectionPadding = EdgeInsets.all(12);
  static const EdgeInsets buttonMargin = EdgeInsets.symmetric(vertical: 8);

  static const BoxDecoration sectionDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
  );

  static const InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  // Additional styles for better UI
  static const TextStyle noteStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  );

  static const EdgeInsets buttonSpacing = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets sectionSpacing = EdgeInsets.only(bottom: 16);
}
