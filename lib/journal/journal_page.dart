import 'package:flutter/material.dart';

import 'journal_editing_page.dart';
import '../utils/data.dart';
import 'package:intl/intl.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  bool get wantKeepAlive => true;
  int _selectedIndex = 1;
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
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(Data.userId)
                    .collection("journal")
                    .orderBy('title', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final journalDocs = snapshot.data?.docs;

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: journalDocs?.length ?? 0,
                    itemBuilder: (context, index) {
                      final journalData =
                          journalDocs?[index].data() as Map<String, dynamic>;
                      final timestamp = journalData['title'] as Timestamp;
                      var format = DateFormat('H:m d-M-y');

                      final title = format.format(timestamp.toDate());
                      final content = journalData['content'] as String;
                      final documentId = journalDocs?[index].id;

                      return Card(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: ListTile(
                          title: Text(
                            title.toString(),
                            style: const TextStyle(fontSize: 25),
                          ),
                          subtitle: Text(content),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JournalEditingPage(
                                    journalTitle: title.toString(),
                                    journalContent: content,
                                    documentId: documentId,
                                    userId: userId.toString()),
                              ),
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
              builder: (context) => JournalEditingPage(
                journalTitle: '',
                journalContent: '',
                documentId: null,
                userId: userId
                    .toString(), // Pass null as document ID for a new journal
              ),
            ),
          );
        },
      ),
    );
  }
}
