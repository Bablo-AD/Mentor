import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoreText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const CoreText({
    required this.text,
    Key? key,
    this.style = const TextStyle(
      fontWeight: FontWeight.normal,
      color: Color.fromARGB(255, 50, 204, 102),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }
}

class CoreScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CoreScaffold({
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: CoreText(text: title),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ));
  }
}

class CoreTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String label;

  const CoreTextField({
    required this.label,
    this.controller,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        labelText: label,
        prefixIcon: const Icon(
          Icons.search,
          color: Color.fromARGB(255, 50, 204, 102),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 19, 19, 19),
      ),
    );
  }
}

class CoreElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Color? bgcolor;
  const CoreElevatedButton(
      {this.bgcolor = const Color.fromARGB(255, 50, 204, 102),
      required this.label,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgcolor,
        ),
        child: CoreText(text: label));
  }
}

class CoreBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  const CoreBottomNavigationBar({required this.selectedIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 50, 204, 102),
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.black,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/mentor');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/journal');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
