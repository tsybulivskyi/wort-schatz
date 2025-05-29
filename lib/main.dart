import 'package:flutter/material.dart';
import 'package:wort_schatz/components/wordList.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'WortSchatz'),
    );
  }
}

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
  Database? _database;
  List<Map<String, dynamic>> _texts = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'user_texts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE texts(id INTEGER PRIMARY KEY, original NVARCHAR(255), translation NVARCHAR(255))',
        );
      },
      onOpen: (db) {
        db.execute('DROP TABLE IF EXISTS texts');
        return db.execute(
          'CREATE TABLE texts(id INTEGER PRIMARY KEY, original NVARCHAR(255), translation NVARCHAR(255))',
        );
        // return db.execute('DELETE FROM texts');
      },
      version: 3,
    );
    await _fetchTexts();
  }

  Future<void> _fetchTexts() async {
    if (_database == null) return;
    final texts = await _database!.query('texts', orderBy: 'id DESC');
    setState(() {
      _texts = texts;
    });
  }

  Future<void> _saveText(String original, String translation) async {
    if (_database == null) return;
    await _database!.insert('texts', {
      'original': original,
      'translation': translation,
    });
    await _fetchTexts();
  }

  Future<void> _saveTextDialog() async {
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
                  await _saveText(original, translation);
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
        centerTitle: true, // Add this line to center the title horizontally
        title: Text(widget.title),
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
            WordList(texts: _texts),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveTextDialog();
        },
        tooltip: 'Add Text',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
