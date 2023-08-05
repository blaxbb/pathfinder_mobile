import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pathfinder_mobile/Data/session_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;

import '../Data/session.dart';
import 'map_navigate_widget.dart';

class SessionDetailsWidget extends StatefulWidget {
  final Session _session;

  const SessionDetailsWidget(this._session, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SessionDetailsWidgetState(_session);
}

class SessionDetailsWidgetState extends State {
  final Session _session;
  late Future<SessionDetails?> _details;
  bool _tapped = false;

  SessionDetailsWidgetState(this._session);

@override
  void initState() {
    _details = SessionDetails.Get(_session);

  }

  @override
  Widget build(BuildContext context) {
    loadFavorited();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Info"),
        actions: [
          IconButton(
            onPressed: () async { await setFavorited(); },
            icon: Icon(
              _tapped ? Icons.star : Icons.star_border,
              shadows: [
                Shadow(color: _tapped ? Colors.black : Colors.transparent, offset: const Offset(0,0), blurRadius: 2)
              ]),
            color: _tapped ? Colors.yellow : Colors.black,
          )
        ],
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _titleWidget(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  _timeWidget(),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,                      
                      children: [
                        _locationWidget(),
                        _eventTypeWidget()
                      ],
                    ),
                ]
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    keywordWidget(),
                    interestAreasWidget(),
                    registrationLevelsWidget(),
                    recordingStatusWidget()
                  ]
                ),
              )

            ),
            FutureBuilder(
              future: _details,
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.data?.description != null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(
                            data: snapshot.data!.description,
                            style: { "*": Style(fontSize: FontSize(16))},
                            onLinkTap: (url, attributes, element) => launchUrl(Uri.parse(url ?? "")),
                          ),
                    )
                  );
                }
                return const SizedBox.shrink();
              },
            ),            
            FutureBuilder(
              future: _details,
              builder: (context, snapshot) {
                if(snapshot.hasData && (snapshot.data?.presentations.length ?? 0) > 0) {
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text("Presentations", style: Theme.of(context).textTheme.titleLarge,)),
                       ...snapshot.data!.presentations.map(
                        (p) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(p.timeSlot!.startTime!.simpleTime(), style: Theme.of(context).textTheme.titleLarge,)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.Title ?? '', style: Theme.of(context).textTheme.bodyLarge),
                                    p.speakers.isNotEmpty ? Text("Presenting: ${p.speakers.join(", ")}") : SizedBox.shrink(),
                                    Text(p.timeSlot!.durationText())
                                  ]
                                ),
                              )
                            ],
                          ),
                        ),
                      ).toList()
                    ])
                  );
                }
                
                return const SizedBox.shrink();
              },
            )
          ],
        )
      ),
    );
  }

  Future<void> loadFavorited() async {
    final prefs = await SharedPreferences.getInstance();
    if(mounted)
    {
      setState(() {
        var id = _session.id;
        _tapped = prefs.getBool("favorite_$id") ?? false;
      });
    }
  }

  Future<void> setFavorited() async {
    var state = !_tapped;
    setState(() {
      _tapped = state;
    });

    final prefs = await SharedPreferences.getInstance();
    var id = _session.id;
      if(state) {
        prefs.setBool("favorite_$id", true);
      }
      else {
        prefs.remove("favorite_$id");
      }
  }  

  Widget _titleWidget() {
    return Row(
      children: [
        Expanded(child: Text(_session.title!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24))),
        _session.Location != null ? IconButton(
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MapNavigateWidget(_session.Location!))
            );
          },
          icon: const Icon(Icons.map)
        ) : SizedBox.shrink()
      ],
    );
  }

  Widget _timeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      Column(
        children: [
          Text("Start Time", style: Theme.of(context).textTheme.titleLarge),
          Text(
              "${DateFormat(DateFormat.ABBR_MONTH_DAY).format(_session.timeSlot!.startTime!.uTC!.subtract(const Duration(hours: 7)))} ${_session.timeSlot!.startTime!.simpleTime()}",
              style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
      Column(
        children: [
          Text("End Time", style: Theme.of(context).textTheme.titleLarge),
          Text(_session.timeSlot!.endTime!.simpleTime(),
              style: Theme.of(context).textTheme.bodyMedium)
        ],
      )
    ]);
  }

  Widget _locationWidget() {
    return Column( children: [
              Text("Location", style: Theme.of(context).textTheme.titleLarge),
              Text(_session.Location ?? "", style: Theme.of(context).textTheme.bodyMedium)
            ],);
  }

  Widget _eventTypeWidget() {
    return Column( children: [
              Text("Event Type", style: Theme.of(context).textTheme.titleLarge),
              Text(_session.EventType ?? "", style: Theme.of(context).textTheme.bodyMedium)
            ],);
  }  

  Widget keywordWidget() => listTagWidget("Keywords", _session.keywords());
  Widget interestAreasWidget() => listTagWidget("Interest Areas", _session.interestAreas());
  Widget registrationLevelsWidget() => listTagWidget("Registration Level", _session.registrationLevels());
  Widget recordingStatusWidget() => listTagWidget("Recording Status", _session.recordingStatus());

  Widget listTagWidget(String title, List<Tag> values) {
    return listPropWidget(title, values.map((e) => e.name ?? ''));
  }

  Widget listPropWidget(String title, Iterable<String> values) {
    if(values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
            children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge,),
            Text(values.join(" - "), style: Theme.of(context).textTheme.bodyMedium)
            ]),
    );
  }  

}