import 'dart:convert';

import 'package:pathfinder_mobile/Widgets/session_category_widget.dart';
import 'package:pathfinder_mobile/Widgets/session_index_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Data/session.dart';
import 'Widgets/session_favorites_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        "/schedule": (context) => const SizedBox.shrink(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

  Future<List<Session>> readJson() async {
    final String response = await rootBundle.loadString('assets/sessions.json');
    final Iterable data = await jsonDecode(response);
    return List<Session>.from(data.map((e) => Session.fromJson(e)));
  }

  var all = readJson();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Featured Sessions"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue
              ),
              child: Text("SIGGRAPH Pathfinder"),
            ),
            ListTile(
              title: const Text("All"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => const SessionIndexWidget()))
              .then((value) {Navigator.pop(context); all = readJson();}),
            ),
            ListTile(
              title: const Text("Favorites"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => const SessionFavoritesWidget()))
              .then((value) {Navigator.pop(context); all = readJson();}),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Session>>(
        future: all,
        builder: (context, snapshot) {
          if(!snapshot.hasData)
          {
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError)
          {
            return const Text("Error loading session info.");
          }
          else
          {
            return ListView(
              children: [
                SessionCategoryWidget(snapshot.data!.where((element) => element.track!.id == 42130 && element.timeSlot!.startTime!.eventTime!.day == 8).toList(), title: "Featured Speakers",),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SessionCategoryWidget(snapshot.data!.where((element) => element.track!.id == 42131 && element.timeSlot!.startTime!.eventTime!.day == 8).toList(), title: "Frontiers",)
                      ),
                    Expanded(
                      child: SessionCategoryWidget(snapshot.data!.where((element) => element.track!.id == 42137 && element.timeSlot!.startTime!.eventTime!.day == 8).toList(), title: "Production Sessions",),
                    ),
                  ]
                )
              ],
            );
          }
        },
      )
    );
  }
}
