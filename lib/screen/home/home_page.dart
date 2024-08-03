import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../journal/journal_page.dart';
import '../settings/settings_page.dart';
import 'mentor_page.dart';
import '../../utils/loader.dart';
import 'content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController(initialPage: 1);
  Loader loader = Loader();
  @override
  void initState() {
    super.initState();
    loader.loadSelectedApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          ContentPage(),
          MentorPage(),
          JournalPage(), // Replace with your Journal page widget
          SettingsPage(), // Replace with your Settings page widget
        ],
      ),
    );
  }
}
