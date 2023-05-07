import 'package:flutter/material.dart';
import 'package:town/widgets/window.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: WindowTitleBar(
        title: Text('Settings'),
      ),
    );
  }
}