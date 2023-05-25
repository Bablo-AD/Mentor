import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class Video {
  final String title;
  final String videoId;

  Video({required this.title, required this.videoId});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      videoId: json['videoId'] ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bablo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences _prefs;
  final journalController = TextEditingController();
  final interestController = TextEditingController();

  String journal = '';
  String short_journal = '';
  String interest = '';
  String completion = '';
  List<Video> videos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJournalFromPrefs();
  }

  Future<void> _loadJournalFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      journal = _prefs.getString('journal') ?? '';
      short_journal = _prefs.getString('short_journal') ?? '';
      journalController.text = journal;
    });
  }

  Future<void> _saveJournalToPrefs(String value) async {
    setState(() {
      journal = value;
    });
    await _prefs.setString('journal', value);
  }

  Future<void> _saveshort_JournalToPrefs(String value) async {
    setState(() {
      short_journal = value;
    });
    await _prefs.setString('short_journal', value);
  }

  Future<void> fetchVideos() async {
    if (interest.isEmpty || journal.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both Interest and Journal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      videos.clear(); // Clear previous videos
    });

    final url =
        'http://192.168.0.111:5000/recommendation_system/youtube_recommend';
    final short_journal_generator =
        'http://192.168.0.111:5000/recommendation_system/tools/journal2short_journal';

    final body = {
      'interest': interest,
      'journal': journal,
    };

    try {
      final response = await http.put(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        final completion_memory = responseData['completetion_response'];
        responseData.remove('completetion_response');
        final videoList = (responseData)
            .entries
            .map((entry) => Video.fromJson({
                  'title': entry.key,
                  'videoId': entry.value,
                }))
            .toList();

        setState(() {
          videos = videoList;
          completion = completion_memory;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch videos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('An error occurred:'),
              SizedBox(height: 8.0),
              Text(error.toString()), // Display the error message
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bablo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(13.0),
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalPage(
                        journal: journal,
                        onSaveJournal: _saveJournalToPrefs,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          journal.isNotEmpty
                              ? journal
                              : 'Write about yourself and your beliefs',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: interestController,
                        decoration: InputDecoration(
                          hintText: 'Interest',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16.0),
                        onSubmitted: (value) {
                          setState(() {
                            interest = value;
                          });
                          fetchVideos(); // Call your submission method here
                        },
                        onChanged: (value) {
                          setState(() {
                            interest = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: isLoading ? null : fetchVideos,
                      icon: Icon(Icons.search),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                )
              else
                Card(
                    child: ListTile(
                        leading: Icon(Icons.computer),
                        title: Text("Bablo's Recommendation",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(completion))),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final youtubePlayerController = YoutubePlayerController(
                    initialVideoId: video.videoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: false,
                    ),
                  );

                  return SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Card(
                          elevation: 5,
                          child: ListTile(
                            visualDensity: VisualDensity(vertical: 3),
                            onTap: () {
                              _launchURL(video.videoId);
                            },
                            title: Text(video.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: YoutubePlayer(
                              controller: youtubePlayerController,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.amber,
                            ),
                          )));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalPage extends StatefulWidget {
  final String journal;
  final Function(String) onSaveJournal;

  JournalPage({required this.journal, required this.onSaveJournal});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late TextEditingController _journalController;

  @override
  void initState() {
    super.initState();
    _journalController = TextEditingController(text: widget.journal);
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _journalController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Write about yourself and your beliefs',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                widget.onSaveJournal(_journalController.text);
                Navigator.pop(context);
              },
              child: Text('Save Journal'),
            ),
          ],
        ),
      ),
    );
  }
}

_launchURL(String videoId) async {
  final url = 'https://www.youtube.com/watch?v=$videoId';
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}
