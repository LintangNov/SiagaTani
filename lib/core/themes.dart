import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
  );

  static final dark = ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey,
  );
}
