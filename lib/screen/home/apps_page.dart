import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../utils/data.dart';
import '../../utils/loader.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<AppInfo> filteredApps = Data.apps;

  @override
  void initState() {
    super.initState();
    Loader.loadApps().then((_) {
      setState(() {
        filteredApps = Data.apps;
      });
    });
  }

  void _filterApps(String query) {
    setState(() {
      filteredApps = Data.apps
          .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps Page'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: _filterApps,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                return ListTile(
                  title: Text(app.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
