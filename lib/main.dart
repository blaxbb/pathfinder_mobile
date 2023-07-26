import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;

import 'package:pathfinder_mobile/Widgets/session_category_widget.dart';
import 'package:pathfinder_mobile/Widgets/session_index_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Data/session.dart';
import 'Widgets/map_navigate_widget.dart';
import 'Widgets/session_favorites_widget.dart';
import 'Widgets/map_edit_widget.dart';

import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
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
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue
      ),
      themeMode: ThemeMode.system,
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

  Future<void> _pullRefresh() async {
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  Future<List<Session>> readWeb() async {
    //final http.Response response = await http.get(Uri.parse('https://s2023.siggraph.org/wp-content/linklings_snippets/wp_program_view_all_2023-08-${filterDate.toString().padLeft(2, '0')}.txt'));
    final http.Response response = await http.get(Uri.parse('https://s2023.siggraph.org/wp-content/linklings_snippets/wp_program_view_all_2023-08-08.txt'));
    if(response.statusCode >= 200 && response.statusCode < 300) {
      final String body = response.body;
      var doc = parse.parse(response.body);
      var items = doc.querySelectorAll("body > table > tbody > .agenda-item");
      var web = List<Session>.from(items.map((e) => Session.fromHtml(e)));
      return web;
    }

    return [];
  }  

  var all = readWeb();

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
              child: Image(
                isAntiAlias: true,
                image: AssetImage("assets/s2022.png")
              ),
            ),
            ListTile(
              title: const Text("All"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => const SessionIndexWidget()))
              .then((value) {Navigator.pop(context); setState(() {
                
              });}),
            ),
            ListTile(
              title: const Text("Favorites"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => const SessionFavoritesWidget()))
              .then((value) {Navigator.pop(context); setState(() {
                
              });}),
            ),
            ListTile(
              title: const Text("Map"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => MapNavigateWidget("East Building, Ballroom C")))
              .then((value) {Navigator.pop(context); setState(() {
                
              });}),
            ),            
            ListTile(
              title: const Text("Map Edit"),
              onTap: () => Navigator
              .push(context, MaterialPageRoute(builder: (context) => MapEditWidget()))
              .then((value) {Navigator.pop(context); setState(() {
                
              });}),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Session>>(
        future: all,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done)
          {
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError)
          {
            return const Text("Error loading session info.");
          }
          else
          {

            var dt = DateTime.now().toUtc();
            dt = DateTime.utc(2022, 8, Random().nextInt(4) + 8, 12, 30).add(const Duration(hours: 7));

            var upcoming = snapshot.data!.where((s) => s.timeSlot!.startTime!.eventTime!.millisecondsSinceEpoch > dt.millisecondsSinceEpoch)
              .toList();

            return RefreshIndicator(
              onRefresh: _pullRefresh,
              child: ListView(
                children: [
                  SessionCategoryWidget(upcoming.take(8).toList(), title: "Upcoming (Debug: Aug ${dt.day}th 12:30PM)",),
                  SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Keynote' && element.timeSlot!.startTime!.eventTime!.day == dt.day).toList(), title: "Keynotes",),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Frontiers' && element.timeSlot!.startTime!.eventTime!.day == dt.day).toList(), title: "Frontiers",)
                        ),
                      Expanded(
                        child: SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Production Session' && element.timeSlot!.startTime!.eventTime!.day == dt.day).toList(), title: "Production Sessions",),
                      ),
                    ]
                  )
                ],
              ),
            );
          }
        },
      )
    );
  }
}
