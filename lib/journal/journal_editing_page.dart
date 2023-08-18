import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/widget.dart';
import '../core/data.dart';

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
      if (mounted) {
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
      if (mounted) {
        setState(() {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: "Mentor/Journal/Edit",
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
                    child: CoreText(
                      text: journalTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteJournal(widget.documentId);
                    },
                    icon: const Icon(Icons.delete),
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
                  fillColor: Color.fromARGB(255, 19, 19, 19),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  journalContent = value;
                },
              ),
              const SizedBox(height: 16.0),
              CoreElevatedButton(
                onPressed: saveJournalEntry,
                label: "Save Journal",
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
