import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import '../../utils/widgets/line_chart.dart';

import '../../utils/data.dart';
import '../../utils/make_request.dart';
import 'chat_page.dart';
import '../../utils/loader.dart';
import 'apps_page.dart';
import '../settings/apps_selection_page.dart';
import '../../utils/notifications.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final interestController = TextEditingController();

  String result = '';
  bool isLoading = false;
  List<Video> videos = Data.videoList;
  Loader loader = Loader();
  LocalNotificationService notifier = LocalNotificationService();

  //Gets user's usage data
  void _Makerequest() async {
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
      Data.videoList.clear();
    });
    check_permissions();
    DataProcessor dataGetter = DataProcessor();
    //try {
    await dataGetter.execute();
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       isLoading = false;
    //       result = e.toString();
    //     });
    //  }
    //}

    if (mounted) {
      setState(() {
        isLoading = false;
        result = Data.completion_message;
        videos = Data.videoList;
        print(Data.notification_title);
      });
    }
    notifier.showNotificationAndroid(
        Data.notification_title, Data.notification_body);
  }

  @override
  void initState() {
    loader.loadjournal();
    super.initState();
    check_permissions();
    loader.getApiKey();

    loader.loadcompletion().then((completionMessage) {
      setState(() {
        Data.completion_message = completionMessage ?? "";
        result = Data.completion_message;
        if (result == '') {
          isLoading = true;
          _Makerequest();
        }
      });
    });

    if (Data.port_state == false) {
      Data.port_state = true;
      print("portListening");
      Data.port.listen((message) async {
        print(message);

        Data.completion_message = message['completion'] ?? "";
        Data.videoList = message['videoList'] ?? [];
        change_val();
      });
    }
  }

  void change_val() {
    setState(() {
      videos = Data.videoList;
      result = Data.completion_message;
    });
  }

  void check_permissions() async {
    bool? isPermission = await UsageStats.checkUsagePermission();
    if (isPermission == false) {
      PhoneUsage.showPermissionDialog(context);
    }
  }

  String getShortenedText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      return words.sublist(0, wordLimit).join(' ') + '...';
    } else {
      return text;
    }
  }

  void saveJournalEntry() async {
    if (interestController.text.isNotEmpty) {
      loader.addJournal(interestController.text);

      loader.saveJournal();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Got it!')),
      );
      interestController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8FBC8F),
            Color(0xFF006400), // Dark green color
            // Light green color
          ],
        ),
      ),
      child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              Navigator.push(
                context,
                BottomToTopPageRoute(
                  page: const AppsPage(),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CurrentDateTimeWidget(),
                  const SizedBox(height: 12.0),
                  const Center(
                      child: Text(
                    'Your Progress',
                    style: TextStyle(color: Colors.white),
                  )),
                  const LineChartSample2(),
                  const SizedBox(height: 12.0),
                  if (isLoading)
                    const Column(children: [
                      SizedBox(height: 16),
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Mentor is scratching his head",
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        "Please hang on for a while",
                      )
                    ])
                  else
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatPage()),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Mentor",
                                  style: TextStyle(fontSize: 25),
                                ),
                                IconButton(
                                    tooltip: "Reload",
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                        _Makerequest();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh)),
                              ],
                            ),
                            subtitle: Text(
                              "${getShortenedText(result, 20)} \n\n Click to chat with mentor",
                            ),
                          ),
                        )),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: interestController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15.0),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          saveJournalEntry();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const AppsChooser(),
                ],
              ),
            ),
          )),
    ));
  }
}

class AppsChooser extends StatefulWidget {
  const AppsChooser({super.key});

  @override
  State<AppsChooser> createState() => _AppsChooserState();
}

class _AppsChooserState extends State<AppsChooser> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code runs after the widget is built
      // Add your items to the sink here
      Data.appSink.add(Data
          .selected_apps); // Replace `addItemToSink` and `yourItem` with your actual method and item
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Application>>(
      stream: Data.appStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final appDocs = snapshot.data!;
        return Card(
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppsPage()),
                  );
                },
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppSelectionPage(),
                    ),
                  );
                },
                child: appDocs.isEmpty
                    ? const Text(
                        'Select the apps you want to display by long pressing. If changes didn\'t show up click the home again')
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: 8, // 4x2 grid
                          itemBuilder: (context, index) {
                            if (index < appDocs.length) {
                              final Application app = appDocs[index];

                              return GestureDetector(
                                  onTap: () async {
                                    bool isInstalled =
                                        await DeviceApps.isAppInstalled(
                                            app.packageName);
                                    if (isInstalled) {
                                      DeviceApps.openApp(app.packageName);
                                    }
                                  },
                                  child: app is ApplicationWithIcon
                                      ? Image.memory(
                                          app.icon,
                                        )
                                      : const Icon(Icons.app_blocking));
                            } else {
                              return const SizedBox
                                  .shrink(); // Empty space if less than 8 apps
                            }
                          },
                        ))));
      },
    );
  }
}

class CurrentDateTimeWidget extends StatelessWidget {
  const CurrentDateTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Column(
      children: [
        Text(
          timeFormat.format(now),
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          dateFormat.format(now),
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }
}

class BottomToTopPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  BottomToTopPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
