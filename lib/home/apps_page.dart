import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

import '../core/widget.dart';
import '../core/data.dart';
import '../core/loader.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});
  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<Application> loadedApps = Data.loadedApps;
  List<Application> filteredApps = [];

  void reloadapp() async {
    loadedApps = await Loader.loadApps();
    setState(() {
      loadedApps = Data.loadedApps;
    });
  }

  @override
  void initState() {
    super.initState();
    reloadapp();
  }

  void _filterApps(String query) {
    setState(() {
      filteredApps = loadedApps
          .where(
              (app) => app.appName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: "Mentor/Apps",
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: CoreTextField(label: 'Search', onChanged: _filterApps)),
          Expanded(
            child: ListView.builder(
              itemCount: loadedApps.length,
              itemBuilder: (context, index) {
                final Application app = loadedApps[index];
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
                        title: CoreText(
                          text: app.appName,
                        )),
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
