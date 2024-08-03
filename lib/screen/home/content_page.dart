import 'package:flutter/material.dart';

import '../../utils/loader.dart';
import '../../utils/data.dart';
import 'video_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List<Video> videos = Data.videoList;
  Loader loader = Loader();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loader.loadVideoList().then((value) {
      setState(() {
        videos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor/Content'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];

                return Card(
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ));
              }),
        ));
  }
}
