import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSelectionPage extends StatefulWidget {
  const AppSelectionPage({super.key});

  @override
  _AppSelectionPageState createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage> {
  List<Application> selectedApps = [];
  List<Application> installedApps = [];
  loadApps() async {
    List<Application> loadedApps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    setState(() {
      installedApps = loadedApps;
    });

    _loadSelectedApps();
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> _loadSelectedApps() async {
    final SharedPreferences prefs = await _prefs;
    List<String>? selectedAppNames = prefs.getStringList('selectedApps');
    if (selectedAppNames != null) {
      setState(() {
        selectedApps = installedApps
            .where((app) => selectedAppNames.contains(app.appName))
            .toList();
      });
    }
  }

  Future<void> _saveSelectedApps() async {
    final SharedPreferences prefs = await _prefs;
    List<String> selectedAppNames =
        selectedApps.map((app) => app.appName).toList();
    await prefs.setStringList('selectedApps', selectedAppNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor/Apps/Selection',
          style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: installedApps.length,
              itemBuilder: (context, index) {
                final Application app = installedApps[index];
                return Column(
                  children: [
                    CheckboxListTile(
                      activeColor: const Color.fromARGB(255, 50, 204, 102),
                      tileColor: const Color.fromARGB(255, 19, 19, 19),
                      title: Text(
                        app.appName,
                        style:
                            const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                      ),
                      value: selectedApps.contains(app),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            selectedApps.add(app);
                          } else {
                            selectedApps.remove(app);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          await _saveSelectedApps();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
