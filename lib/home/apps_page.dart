import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../core/loader.dart';
import '../core/data.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<Application> filteredApps = Data.apps;
  @override
  void initState() {
    super.initState();
    Loader.loadApps();
  }

  void _filterApps(String query) {
    setState(() {
      filteredApps = Data.apps
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
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterApps, // Call _filterApps when the text changes
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(
                  Icons.search,
                ),
                filled: true,
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
