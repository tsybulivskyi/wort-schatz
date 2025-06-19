import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wort_schatz/components/wordList.dart';
import 'package:wort_schatz/domain/word.dart';
import 'package:wort_schatz/main.dart';

import 'config.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Word> _words = [];

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  Future<void> _fetchWords() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      var token = await currentUser?.getIdToken();
      print('User token: ' + (token ?? 'No token'));
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/words'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final List<Word> words =
            data.map((wordData) => Word.fromJson(wordData)).toList();
        setState(() {
          _words = words;
        });
      } else if (res.statusCode == 401) {
        // Unauthorized: Show error box
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Unauthorized'),
                  content: const Text(
                    'Your session has expired or you are not authorized.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
        setState(() {
          _words = [];
        });
      } else {
        // Handle error or fallback
        setState(() {
          _words = [];
        });
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar or log)
      setState(() {
        _words = [];
      });
    }
  }

  Future<void> _saveWord(String original, String translation) async {
    // Call the backend endpoint to POST /words
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/words'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'original': original, 'translation': translation}),
      );
      if (res.statusCode != HttpStatus.created) {
        throw Exception('Failed to save word to backend');
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar or log)
    }

    await _fetchWords();
  }

  Future<void> _saveWordDialog() async {
    String original = '';
    String translation = '';
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                onChanged: (value) {
                  original = value;
                },
                decoration: const InputDecoration(hintText: 'Original'),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  translation = value;
                },
                decoration: const InputDecoration(hintText: 'Translation'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (original.trim().isNotEmpty &&
                    translation.trim().isNotEmpty) {
                  await _saveWord(original, translation);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllWords() async {
    try {
      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/words'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != HttpStatus.noContent &&
          res.statusCode != HttpStatus.ok) {
        throw Exception('Failed to delete words');
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar or log)
    }
    await _fetchWords();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
        // The hamburger menu is shown automatically if a drawer is present
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: Text('Word count: ${_words.length}'),
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Tags'),
              onTap: () {
                Navigator.of(context).pop();
                // You can add navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete All Words',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.of(context).pop(); // Close the drawer
                await _deleteAllWords();
              },
            ),
            // Add more menu items here
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 24),
            const Text('Deine Worte:'),
            WordList(texts: _words),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveWordDialog();
        },
        tooltip: 'Add Text',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
