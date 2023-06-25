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
  List<Application> sortedApps = [];
  List<Application> filteredApps = [];

  @override
  void initState() {
    super.initState();
    sortedApps = List<Application>.from(widget.apps);
    sortedApps.sort((a, b) => a.appName.compareTo(b.appName));
    filteredApps = sortedApps; // Initialize filteredApps with all apps
  }

  void _filterApps(String query) {
    setState(() {
      filteredApps = sortedApps
          .where(
              (app) => app.appName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor/Apps',
          style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              onChanged: _filterApps, // Call _filterApps when the text changes
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search,
                    color: Color.fromARGB(255, 50, 204, 102)),
                filled: true,
                fillColor: Color.fromARGB(255, 19, 19, 19),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final Application app = filteredApps[index];
                return Column(
                  children: [
                    ListTile(
                      tileColor: const Color.fromARGB(255, 19, 19, 19),
                      onTap: () async {
                        bool isInstalled =
                            await DeviceApps.isAppInstalled(app.packageName);
                        if (isInstalled) {
                          DeviceApps.openApp(app.packageName);
                        }
                      },
                      title: Text(
                        app.appName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 204, 102),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
