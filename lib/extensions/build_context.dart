import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';

extension ThemeExtension on BuildContext {
  ThemeColors get colors => Theme.of(this).brightness == Brightness.dark ? darkColors : lightColors;
}
