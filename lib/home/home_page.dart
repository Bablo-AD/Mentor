import '../core/data.dart';
import '../core/widget.dart';
import 'make_request.dart';
import '../journal/journal_editing_page.dart';
import 'video_page.dart';
import 'chat_page.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  _MentorPageState createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final int _selectedIndex = 0;
  final interestController = TextEditingController();

  String interest = '';
  String result = '';
  bool isLoading = false;
  List<Messages> messages_data = [];
  List<Video> videos = [];

  //Gets user's usage data
  void _Makerequest(String interest) async {
    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
      Data.videoList.clear();
    });
    DataProcessor dataGetter = DataProcessor(context);
    try {
      dataGetter.execute(interest);
    } catch (e) {
      setState(() {
        isLoading = false;
        result = e.toString();
      });
    }

    setState(() {
      isLoading = false;
      result = Data.completion_message;
      videos = Data.videoList;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
        title: 'Mentor',
        body: SingleChildScrollView(
          // Wrap the body with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

                    if (journalDocs == null || journalDocs.isEmpty) {
                      return const CoreText(text: 'No journals available.');
                    }

                    final lastJournalData =
                        journalDocs[0].data() as Map<String, dynamic>;
                    final lastJournalTitle =
                        lastJournalData['title'].toDate().toString();
                    final lastJournalContent =
                        lastJournalData['content'] as String;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: const Color.fromARGB(255, 19, 19, 19),
                          child: ListTile(
                            title: CoreText(
                              text: lastJournalTitle,
                            ),
                            subtitle: CoreText(
                              text: lastJournalContent,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalEditingPage(
                                    journalTitle: lastJournalTitle,
                                    journalContent: lastJournalContent,
                                    documentId: journalDocs[0].id,
                                    userId: Data.userId.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                if (isLoading)
                  const Column(children: [
                    SizedBox(height: 16),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 10.0),
                    CoreText(
                      text: "YOLO",
                    )
                  ])
                else
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(response: result)),
                        );
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 19, 19, 19),
                        child: ListTile(
                          title: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _Makerequest(interest);
                                },
                                icon: const Icon(Icons.refresh,
                                    color: Color.fromARGB(255, 50, 204, 102)),
                              ),
                              const Text(
                                "Mentor: ",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 50, 204, 102),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            result,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 50, 204, 102),
                            ),
                          ),
                        ),
                      )),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofillHints: const <String>[
                          'I want to exercise daily',
                          'I want to read daily'
                        ],
                        controller: interestController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Your Goal',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Color.fromARGB(255, 50, 204, 102),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            interest = value;
                          });
                          _Makerequest(
                              interest); // Call your submission method here
                        },
                        onChanged: (value) {
                          setState(() {
                            interest = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed:
                          isLoading ? null : () => _Makerequest(interest),
                      icon: const Icon(Icons.search),
                      color: const Color.fromARGB(255, 50, 204, 102),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    return Card(
                        color: const Color.fromARGB(255, 19, 19, 19),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPage(
                                    videoId: video.videoId,
                                    description: video.videoDescription),
                              ),
                            );
                          },
                          title: Text(
                            video.title,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 50, 204, 102),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ));
                  },
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            CoreBottomNavigationBar(selectedIndex: _selectedIndex));
  }
}
