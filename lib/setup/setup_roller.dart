import 'package:Mentor/settings/preferred_time.dart';
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
// class SetupPage extends StatelessWidget {
//   const SetupPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigateToNextPage(context);
//     });
//     return WillPopScope(
//       onWillPop: () async {
//         // Handle the back button press
//         // If on Set Goal and Purpose page, pop and return to previous screen
//         // If on Setup Home Screen Apps page, pop and return to Set Goal and Purpose page
//         // If on Connect with Habitica page, pop and return to Setup Home Screen Apps page
//         // If on the new page, prevent popping and return false to disable the back button
//         if (ModalRoute.of(context)?.settings.name == '/knowingthestudent') {
//           return true;
//         } else if (ModalRoute.of(context)?.settings.name ==
//             '/appSelectionPage') {
//           Navigator.pop(context); // Pop to Set Goal and Purpose page
//           return false;
//         } else if (ModalRoute.of(context)?.settings.name == '/preferredtime') {
//           Navigator.pop(context); // Pop to Set Goal and Purpose page
//           return false;
//         } else {
//           return false; // Disable back button on the new page
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Mentor/Setup',
//             style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
//           ),
//           backgroundColor: Colors.black,
//         ),
//         backgroundColor: Colors.black,
//         body: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }

//   void navigateToNextPage(BuildContext context) {
//     Future.delayed(Duration.zero, () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PrivacyPolicy(),
//         ),
//       ).then((_) {
//         // Navigate to Set Goal and Purpose page
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TermsAndConditionsScreen(),
//           ),
//         );
//       }).then((_) {
//         // Navigate to Set Goal and Purpose page
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const Knowingthestudent(),
//           ),
//         );
//       }).then((_) {
//         // After Connect with Habitica page is closed, navigate to the new page
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 const AppSelectionPage(), // Replace with the new page
//           ),
//         );
//       }).then((_) {
//         // After Connect with Habitica page is closed, navigate to the new page
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 PreferredTimePage(), // Replace with the new page
//           ),
//         );
//       }).then((_) {
//         // After Connect with Habitica page is closed, navigate to the new page
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 const MentorPage(), // Replace with the new page
//           ),
//         );
//       });
//     });
//   }
// }
