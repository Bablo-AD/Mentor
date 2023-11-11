import 'package:flutter/material.dart';
import '../settings/knowingthestudent.dart';
import '../settings/habitica_integration_page.dart';
import '../home/home_page.dart';
import '../home/make_request.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToNextPage(context);
    });
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press
        // If on Set Goal and Purpose page, pop and return to previous screen
        // If on Setup Home Screen Apps page, pop and return to Set Goal and Purpose page
        // If on Connect with Habitica page, pop and return to Setup Home Screen Apps page
        // If on the new page, prevent popping and return false to disable the back button
        if (ModalRoute.of(context)?.settings.name == '/knowingthestudent') {
          return true;
        } else if (ModalRoute.of(context)?.settings.name ==
            '/appSelectionPage') {
          Navigator.pop(context); // Pop to Set Goal and Purpose page
          return false;
        } else if (ModalRoute.of(context)?.settings.name ==
            '/habiticaIntegrationPage') {
          Navigator.pop(context); // Pop to Setup Home Screen Apps page
          return false;
        } else {
          return false; // Disable back button on the new page
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mentor/Setup',
            style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
          ),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void navigateToNextPage(BuildContext context) {
    Future.delayed(Duration.zero, () {
      // Navigate to Set Goal and Purpose page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Knowingthestudent(),
        ),
      ).then((_) {
        // After Setup Home Screen Apps page is closed, navigate to Connect with Habitica page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HabiticaIntegrationPage(),
          ),
        ).then((_) {
          // After Connect with Habitica page is closed, navigate to the new page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const MentorPage(), // Replace with the new page
            ),
          );
        });
      });
    });
  }
}
