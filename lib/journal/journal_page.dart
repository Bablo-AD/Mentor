import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'journal_editing_page.dart';
import '../core/widget.dart';
import '../core/data.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final int _selectedIndex = 1;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: "Mentor/Journal",
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
                      final title = journalData['title'] as Timestamp;
                      final content = journalData['content'] as String;
                      final documentId = journalDocs?[index].id;

                      return Card(
                        color: const Color.fromARGB(255, 19, 19, 19),
                        child: ListTile(
                          title: CoreText(
                            text: title.toDate().toString(),
                          ),
                          subtitle: CoreText(
                            text: content,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JournalEditingPage(
                                    journalTitle: title.toDate().toString(),
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
      floatingActionButton: FloatingActionButton(
        foregroundColor: const Color.fromARGB(255, 19, 19, 19),
        backgroundColor: const Color.fromARGB(255, 50, 204, 102),
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
      bottomNavigationBar: CoreBottomNavigationBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
