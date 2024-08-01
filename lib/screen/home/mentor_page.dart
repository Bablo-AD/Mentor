import 'package:intl/intl.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import '../../utils/widgets/line_chart.dart';

import '../../utils/data.dart';
import '../../utils/make_request.dart';
import '../journal/journal_editing_page.dart';
import 'video_page.dart';
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

  String interest = '';
  String result = '';
  bool isLoading = false;
  List<Video> videos = Data.videoList;
  Loader loader = Loader();

  String serverurl = '';
  LocalNotificationService notifier = LocalNotificationService();
  List<Application> loadedApps = [];

  //Gets user's usage data
  void _Makerequest(String interest) async {
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
    loader.loadVideoList().then((value) {
      setState(() {
        videos = value;
      });
    });
    loader.loadcompletion().then((completionMessage) {
      setState(() {
        Data.completion_message = completionMessage ?? "";
        result = Data.completion_message;
        if (result == '') {
          isLoading = true;
          _Makerequest(interest);
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
      child: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 60, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CurrentDateTimeWidget(),
              const SizedBox(height: 16.0),
              const Center(
                  child: Text(
                'Your Progress',
                style: TextStyle(color: Colors.white),
              )),
              const LineChartSample2(),
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
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
                                    _Makerequest(interest);
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
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const AppsChooser(),
              const SizedBox(height: 16.0),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];

                  return Card(
                      child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPage(
                              videoId: video.videoId,
                              description: video.videoDescription),
                        ),
                      );
                    },
                    title: Text(
                      video.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ));
                },
              )
            ],
          ),
        ),
      ),
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
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 8, // 4x2 grid
          itemBuilder: (context, index) {
            if (index < appDocs.length) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(appDocs[index].icon, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    appDocs[index].name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink(); // Empty space if less than 8 apps
            }
          },
        );
        Card(
          child: ListTile(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSelectionPage(),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppsPage()),
              );
            },
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Apps",
                  style: TextStyle(fontSize: 25),
                ),
                Icon(
                  Icons.expand,
                )
              ],
            ),
            subtitle: appDocs.isEmpty
                ? const Text(
                    'Select the apps you want to display by long pressing. If changes didn\'t show up click the home again')
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: appDocs.length,
                    itemBuilder: (context, index) {
                      final Application app = appDocs[index];
                      return ListTile(
                        onTap: () async {
                          bool isInstalled =
                              await DeviceApps.isAppInstalled(app.packageName);
                          if (isInstalled) {
                            DeviceApps.openApp(app.packageName);
                          }
                        },
                        title: Text('- ${app.appName}'),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class CurrentDateTimeWidget extends StatelessWidget {
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
