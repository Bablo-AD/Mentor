import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

import '../core/loader.dart';
import '../core/data.dart';
import '../core/widget.dart';

class AppSelectionPage extends StatefulWidget {
  const AppSelectionPage({super.key});

  @override
  _AppSelectionPageState createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage> {
  List<Application> selectedApps = Data.selectedApps;
  List<Application> installedApps = Data.loadedApps;
  Loader _loader = Loader();

  void _loadstuff() async {
    await Loader.loadApps();
    await _loader.loadselectedApps;
    setState() {
      selectedApps = Data.selectedApps;
      installedApps = Data.loadedApps;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadstuff();
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: "Mentors/App/Selection",
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: installedApps.length,
              itemBuilder: (context, index) {
                final Application app = installedApps[index];
                return Column(
                  children: [
                    Theme(
                        data: ThemeData(
                          unselectedWidgetColor:
                              Color.fromARGB(255, 50, 204, 102),
                        ),
                        child: CheckboxListTile(
                          activeColor: const Color.fromARGB(255, 50, 204, 102),
                          checkColor: const Color.fromARGB(255, 19, 19, 19),
                          tileColor: const Color.fromARGB(255, 19, 19, 19),
                          title: CoreText(
                            text: app.appName,
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
                        )),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Color.fromARGB(255, 50, 204, 102),
        foregroundColor: Color.fromARGB(255, 19, 19, 19),
        child: const Icon(Icons.check),
        onPressed: () async {
          await _loader.saveSelectedApps();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
