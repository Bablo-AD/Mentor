import '../screen/settings/preferred_time.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _introKey = GlobalKey<IntroductionScreenState>();
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Set your preferred time',
          bodyWidget: const PreferredTimeSelection(),
        ),
        PageViewModel(
            title: 'How this works?',
            image: const Center(
              child: Icon(Icons.lock, size: 100.0),
            ),
            body:
                'This app collects information from your phone and journal data, then sends it to our server. Our AI processes this data and uses books, research articles to provide you with the best content.We don\'t store any of the data on our servers except journal data. Everything else is stored on your phone locally.'),
      ],
      showNextButton: true,
      next: const Text("Next"),
      showDoneButton: true,
      done: const Text("Done"),
      onDone: () {
        Navigator.pushReplacementNamed(context, '/mentor');
      },
    );
  }
}
