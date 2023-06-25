import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_editing_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor/Journals',
          style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 50, 204, 102),
                ),
                child: const Text('New Journal'),
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('journals')
                    .where('userId', isEqualTo: userId)
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
                          title: Text(
                            title.toDate().toString(),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 50, 204, 102)),
                          ),
                          subtitle: Text(
                            content,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 50, 204, 102)),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 50, 204, 102),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MentorPage()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const JournalPage()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
              break;
          }
        },
      ),
    );
  }
}
