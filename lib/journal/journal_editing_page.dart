import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/data.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

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
  late String journalTitle;
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();

    if (widget.journalTitle.isEmpty) {
      var format = DateFormat('H:m d-M-y');
      journalTitle = format.format(DateTime.now()).toString();
    } else {
      journalTitle = widget.journalTitle;
    }

    _quillController = QuillController(
      document: Document.fromJson(json.decode(widget.journalContent)),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void saveJournalEntry() async {
    String content = _quillController.document.toPlainText();

    if (content.isNotEmpty) {
      if (widget.documentId != null) {
        // Existing journal, update it
        await FirebaseService().updateJournal(widget.documentId!, content);
      } else {
        // New journal, create it
        await FirebaseService().createJournal(content);
      }

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
    String? documentId = widget.documentId;
    if (documentId != null) {
      await FirebaseService().deleteJournal(documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal deleted!')),
      );

      if (mounted) {
        setState(() {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mentor/Journal/Edit")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(journalTitle),
            const SizedBox(height: 16.0),
            Expanded(
                child: QuillProvider(
              configurations: QuillConfigurations(
                controller: _quillController,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('de'),
                ),
              ),
              child: Column(
                children: [
                  const QuillToolbar(),
                  Expanded(
                    child: QuillEditor.basic(
                      configurations: const QuillEditorConfigurations(
                        readOnly: false,
                      ),
                    ),
                  )
                ],
              ),
            )),
            const SizedBox(height: 16.0),
            FilledButton(
              onPressed: saveJournalEntry,
              child: Text("Save Journal"),
            ),
            const SizedBox(height: 8.0),
            OutlinedButton(
              onPressed: deleteJournal,
              child: Text("Delete Journal"),
            ),
          ],
        ),
      ),
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createJournal(String content) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    await _firestore
        .collection('users')
        .doc(Data.userId)
        .collection("journal")
        .add({
      'userId': userId,
      'title': DateTime.now(),
      'content': content,
    });
  }

  Future<void> deleteJournal(String documentId) async {
    await _firestore
        .collection('users')
        .doc(Data.userId)
        .collection("journal")
        .doc(documentId)
        .delete();
  }

  Future<void> updateJournal(String documentId, String content) async {
    await _firestore
        .collection('users')
        .doc(Data.userId)
        .collection("journal")
        .doc(documentId)
        .update({
      'content': content,
    });
  }
}
