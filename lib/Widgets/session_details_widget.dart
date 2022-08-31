import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _tapped = false;

  SessionDetailsWidgetState(this._session);

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
                  _locationWidget(),
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
                  ]
                ),
              )

            ),
            Card(
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableHtml(
                  style: {
                    "div": Style(fontSize: const FontSize(16))
                  },
                  data: _session.description,
                  onLinkTap: (url, context, attributes, element) => launchUrl(Uri.parse(url ?? "")),
                ),
              )
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
        IconButton(
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MapNavigateWidget(_session.room!.name!))
            );
          },
          icon: Icon(Icons.map)
        )        
      ],
    );
  }

  Widget _timeWidget()
  {
    return Row(children: [
      Expanded(
        child: Column( children: [
          Text("Start Time", style: Theme.of(context).textTheme.titleLarge),
          Text("${DateFormat(DateFormat.ABBR_MONTH_DAY).format(_session.timeSlot!.startTime!.uTC!.subtract(const Duration(hours: 7)))} ${_session.timeSlot!.startTime!.simpleTime()}", style: Theme.of(context).textTheme.bodyMedium)
        ],)
      ),
      Expanded(
        child: Column( children: [
          Text("End Time", style: Theme.of(context).textTheme.titleLarge),
          Text(_session.timeSlot!.endTime!.simpleTime(), style: Theme.of(context).textTheme.bodyMedium)
        ],),
      )        
    ]);
  }

  Widget _locationWidget() {
    return Row(children: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column( children: [
              Text("Location", style: Theme.of(context).textTheme.titleLarge),
              Text(_session.room?.name ?? "", style: Theme.of(context).textTheme.bodyMedium)
            ],)
          ],
        )
      ),
      Expanded(
        child: Column( children: [
          Text("Format", style: Theme.of(context).textTheme.titleLarge),
          Text(_session.format(), style: Theme.of(context).textTheme.bodyMedium)
        ],)
      )
    ]);
  }

  Widget keywordWidget() => listPropWidget("Keywords", _session.keywords());
  Widget interestAreasWidget() => listPropWidget("Interest Areas", _session.interestAreas());
  Widget registrationLevelsWidget() => listPropWidget("Registration Level", _session.registrationLevels());

  Widget listPropWidget(String title, List<String> values) {
    if(values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge,),
          Text(values.join(" - "), style: Theme.of(context).textTheme.bodyMedium)
          ]),
      );
  }

}