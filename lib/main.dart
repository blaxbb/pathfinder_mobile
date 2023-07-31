import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;
import 'package:intl/intl.dart';

import 'package:pathfinder_mobile/Widgets/session_category_widget.dart';
import 'package:pathfinder_mobile/Widgets/session_index_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Data/session.dart';
import 'Widgets/map_navigate_widget.dart';
import 'Widgets/session_favorites_widget.dart';
import 'Widgets/map_edit_widget.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tzs;

void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    return MaterialApp(
      title: 'SIGGRAPH 2023',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'SIGGRAPH 2023'),
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

  DateTime? time;
  late Future<List<Session>> Items;

  Future<void> _pullRefresh() async {
      setState(() {});
  }

  @override
  void initState() {
    Future<List<Session>> readWeb() async {
      final timeZone = tzs.getLocation('America/Los_Angeles');

      var currentTime = tzs.TZDateTime.now(timeZone);
      var eventStartTime = tzs.TZDateTime.from(DateTime.utc(2023, 08, 06, 13), timeZone);
      if(eventStartTime.isAfter(currentTime)) {
        currentTime = eventStartTime;
      }
      
      time = currentTime;

      var uri = Uri.parse('https://s2023.siggraph.org/wp-content/linklings_snippets/wp_program_view_all_2023-08-${time!.day.toString().padLeft(2, '0')}.txt');
      final http.Response response = await http.get(uri);
      // final http.Response response = await http.get(Uri.parse('https://s2023.siggraph.org/wp-content/linklings_snippets/wp_program_view_all_2023-08-08.txt'));
      if(response.statusCode >= 200 && response.statusCode < 300) {
        final String body = response.body;
        var doc = parse.parse(response.body);
        var items = doc.querySelectorAll("body > table > tbody > .agenda-item");
        var web = List<Session>.from(items.map((e) => Session.fromHtml(e)));
        return web;
      }

      return [];
    }  

    Items = readWeb();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Featured Sessions"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
        ],
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
              .push(context, MaterialPageRoute(builder: (context) => MapNavigateWidget("Pathfinders")))
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
        future: Items,
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
            var upcoming = snapshot.data!.where((s) => s.timeSlot!.startTime!.eventTime!.millisecondsSinceEpoch > time!.millisecondsSinceEpoch)
              .toList();

            bool wideScreen = MediaQuery.of(context).size.width > 800;

            return RefreshIndicator(
              onRefresh: _pullRefresh,
              child: ListView(
                children: [
                  SessionCategoryWidget(upcoming.take(8).toList(), title: "Upcoming (Updated: ${DateFormat("MMM dd - hh:mm a").format(time!)})",),
                  SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Keynote' && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "Keynotes",),
                  ...(wideScreen ? [Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Frontiers' && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "Frontiers",)
                        ),
                      Expanded(
                        child: SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Production Session' && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "Production Sessions",),
                      ),
                    ]
                  )] : [
                    SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Frontiers' && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "Frontiers",),
                    SessionCategoryWidget(snapshot.data!.where((element) => element.EventType == 'Production Session' && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "Production Sessions",),
                  ]),
                  SessionCategoryWidget(FilterMultiplePosters(snapshot).where((element) => element.timeSlot!.duration().inHours > 4 && element.timeSlot!.startTime!.eventTime!.day == time!.day).toList(), title: "All-Day",),
                ],
              ),
            );
          }
        },
      )
    );
  }

  List<Session> FilterMultiplePosters(AsyncSnapshot<List<Session>> snapshot) {
    var ret = <Session>[];

    bool returnedPosters = false;
    for(var session in snapshot.data!) {
      if(session.EventType == "Poster") {
        if(!returnedPosters && session.timeSlot!.startTime!.eventTime!.day == time!.day)
        {
          session.title = "Posters";
          returnedPosters = true;
          ret.add(session);
        }
      }
      else 
      {
        ret.add(session);
      }  
    }

    return ret;
  }
}
