import 'package:flutter/material.dart';
import '../models/tracker_mode.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  TrackerMode _mode = TrackerMode.movies;

  TrackerMode get mode => _mode;

  ThemeData get themeData {
    return _mode == TrackerMode.movies
        ? AppTheme.dark()
        : AppTheme.light();
  }

  void setMode(TrackerMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }
}
