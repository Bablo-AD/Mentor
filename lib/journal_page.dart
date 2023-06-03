import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  final String journal;
  final Function(String) onSaveJournal;

  const JournalPage(
      {super.key, required this.journal, required this.onSaveJournal});

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
        title: const Text('Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _journalController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Write about yourself and your beliefs',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                widget.onSaveJournal(_journalController.text);
                Navigator.pop(context);
              },
              child: const Text('Save Journal'),
            ),
          ],
        ),
      ),
    );
  }
}
