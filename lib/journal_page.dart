import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  int _selectedIndex = 1;
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
                  backgroundColor: Color.fromARGB(255, 50, 204, 102),
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
                    return CircularProgressIndicator();
                  }

                  final journalDocs = snapshot.data?.docs;

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
            icon: Icon(Icons.notes),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 50, 204, 102),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MentorPage()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => JournalPage()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
              break;
          }
        },
      ),
    );
  }
}

class JournalEditingPage extends StatefulWidget {
  const JournalEditingPage({
    Key? key,
    required this.journalTitle,
    required this.journalContent,
    required this.documentId,
    required this.userId,
  }) : super(key: key);

  final String journalTitle;
  final String journalContent;
  final String? documentId;
  final String userId;
  @override
  _JournalEditingPageState createState() => _JournalEditingPageState();
}

class _JournalEditingPageState extends State<JournalEditingPage> {
  final _firebaseService = FirebaseService();
  late String journalTitle;
  late String journalContent;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    if (widget.journalTitle.isEmpty) {
      journalTitle = DateTime.now().toString();
    } else {
      journalTitle = widget.journalTitle;
    }
    ;

    journalContent = widget.journalContent;
    _contentController = TextEditingController(text: journalContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void saveJournalEntry() async {
    if (journalContent.isNotEmpty) {
      if (widget.documentId != null) {
        // Existing journal, update it
        await _firebaseService.updateJournal(
            widget.documentId!, journalContent);
      } else {
        // New journal, create it
        await _firebaseService.createJournal(journalContent);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved!')),
      );
      if (this.mounted) {
        setState(() {
          Navigator.pop(context);
        });
      }
    }
  }

  void _deleteJournal(String? documentId) async {
    if (documentId != null) {
      await FirebaseService().deleteJournal(documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal deleted!')),
      );
      if (this.mounted) {
        setState(() {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor/Journal/Edit',
            style: TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
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
              Row(
                children: [
                  Expanded(
                    child: Text(journalTitle,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 50, 204, 102))),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteJournal(widget.documentId);
                    },
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style:
                    const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 19, 19, 19),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  journalContent = value;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: saveJournalEntry,
                child: const Text(
                  'Save Journal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createJournal(String content) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    await _firestore.collection('journals').add({
      'userId': userId,
      'title': DateTime.now(),
      'content': content,
    });
  }

  Future<void> deleteJournal(String documentId) async {
    await _firestore.collection('journals').doc(documentId).delete();
  }

  Future<void> updateJournal(String documentId, String content) async {
    await _firestore.collection('journals').doc(documentId).update({
      'content': content,
    });
  }
}
