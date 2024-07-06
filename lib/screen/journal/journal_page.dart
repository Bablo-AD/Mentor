import 'package:flutter/material.dart';

import 'journal_editing_page.dart';
import '../../utils/data.dart';
import '../../utils/loader.dart';
import 'package:intl/intl.dart';
import '../../utils/widgets/line_chart.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  bool get wantKeepAlive => true;
  Loader loader = Loader();
  int _selectedIndex = 1;
  @override
  void initState() {
    loader.loadjournal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mentor/Journal",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LineChartSample2(),
              const SizedBox(height: 16.0),
              StreamBuilder<Map<String, dynamic>>(
                stream: Data.journalStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final journalDocs = snapshot.data!;

                  return journalDocs.isEmpty
                      ? const Text(
                          'Add journal by clicking the "+" button below.')
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: journalDocs.keys.length,
                          itemBuilder: (context, index) {
                            final int reverseIndex =
                                journalDocs.length - 1 - index;

                            final title =
                                journalDocs.keys.elementAt(reverseIndex);
                            final content = journalDocs[title];

                            return Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              child: ListTile(
                                title: Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.parse(title)),
                                  style: const TextStyle(fontSize: 25),
                                ),
                                subtitle: Text(content),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            JournalEditingPage(
                                              journalTitle: title,
                                              journalContent: content,
                                            )),
                                  );
                                },
                              ),
                            );
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("New Day"),
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JournalEditingPage(
                journalTitle: '',
                journalContent:
                    '', // Pass null as document ID for a new journal
              ),
            ),
          );
        },
      ),
    );
  }
}
