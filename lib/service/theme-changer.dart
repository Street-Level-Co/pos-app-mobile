import 'package:flutter/material.dart';

class ThemeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Brightness brightness) builder;
  final Brightness defaultBrightness;
  
  ThemeBuilder({required this.builder, required this.defaultBrightness});

  @override
  State<StatefulWidget> createState() => _ThemeBuilderState();

  // Add this static method to access the state from child widgets
  static _ThemeBuilderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeBuilderState>();
  }
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.defaultBrightness;
  }

  void changeTheme() {
    setState(() {
      _brightness = _brightness == Brightness.dark 
          ? Brightness.light 
          : Brightness.dark;
    });
  }

  Brightness getCurrentBrightness() => _brightness;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness);
  }
}