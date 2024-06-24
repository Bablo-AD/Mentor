import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/loader.dart';
import '../utils/data.dart';

class JournalEditingPage extends StatefulWidget {
  const JournalEditingPage({
    Key? key,
    required this.journalTitle,
    required this.journalContent,
  }) : super(key: key);

  final String journalTitle;
  final String journalContent;
  @override
  _JournalEditingPageState createState() => _JournalEditingPageState();
}

class _JournalEditingPageState extends State<JournalEditingPage> {
  late String journalTitle;
  late String journalContent;
  late TextEditingController _contentController;
  final Loader _loader = Loader();

  @override
  void initState() {
    super.initState();
    if (widget.journalTitle.isEmpty) {
      var format = DateFormat('H:m d-M-y');
      journalTitle = format.format(DateTime.now()).toString();
    } else {
      journalTitle = widget.journalTitle;
    }

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
      if (Data.journal.containsKey(journalTitle)) {
        // Existing journal, update it
        _loader.updateJournal(journalTitle, journalContent);
      } else {
        _loader.addJournal(journalContent);
      }
      _loader.saveJournal();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved!')),
      );
      if (mounted) {
        setState(() {
          Navigator.pop(context);
        });
      }
    }
  }

  void deleteJournal() async {
    _loader.removeJournal(widget.journalTitle);
    _loader.saveJournal();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal deleted!')),
    );
    if (mounted) {
      setState(() {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentor/Journal/Edit")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(journalTitle),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                minLines: 10,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  journalContent = value;
                },
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: saveJournalEntry,
                child: const Text("Save Journal"),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: deleteJournal,
                child: const Text("Delete Journal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
