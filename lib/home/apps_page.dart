import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

Future<List<Application>> loadApps() async {
  List<Application> loaded_apps = await DeviceApps.getInstalledApplications(
    includeSystemApps: true,
    onlyAppsWithLaunchIntent: true,
  );
  return loaded_apps;
}

class AppsPage extends StatefulWidget {
  const AppsPage({super.key, required this.apps});
  final List<Application> apps;
  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
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
                  itemCount: widget.apps.length,
                  itemBuilder: (context, index) {
                    final Application app = widget.apps[index];
                    return Column(children: [
                      ListTile(
                        tileColor: Color.fromARGB(255, 19, 19, 19),
                        onTap: () async {
                          bool isInstalled =
                              await DeviceApps.isAppInstalled(app.packageName);
                          if (isInstalled) {
                            DeviceApps.openApp(app.packageName);
                          }
                        },
                        title: Text(
                          app.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 50, 204, 102),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ]);
                  }))
        ]));
  }
}
