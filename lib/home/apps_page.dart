import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<Application> apps = [];
  @override
  void initState() {
    super.initState();
    loadApps();
  }

  loadApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    apps = apps; //Adding to global variable
    // for (int i = 0; i < apps.length; i++) {
    //   Application app = apps[i];
    //   Text(app.appName);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor/Apps',
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final Application app = apps[index];

                    return ListTile(
                      title: Text(
                        app.appName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 204, 102),
                        ),
                      ),
                    );
                  }))
        ]));
  }
}
