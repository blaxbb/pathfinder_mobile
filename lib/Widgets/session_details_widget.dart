import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Data/session.dart';

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
    
    return Scaffold(
      appBar: AppBar(title: const Text("Session Info")),
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
                    const SizedBox(height: 8),
                    interestAreasWidget(),
                    const SizedBox(height: 8),
                    registrationLevelsWidget(),
                  ]
                ),
              )

            ),
            Card(
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableHtml(
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

  Widget _titleWidget() {
    return Row(
      children: [
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => {
              setState(() {
                _tapped = !_tapped;
              },)
            },
            child: Container(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: Icon(
                _tapped ? Icons.star : Icons.star_border,
                color: _tapped ? Colors.yellow : Colors.black,
                shadows: [
                  Shadow(color: _tapped ? Colors.black : Colors.transparent, offset: const Offset(0,0), blurRadius: 2
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Text(_session.title!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24))),
      ],
    );
  }

  Widget _timeWidget()
  {
    return Row(children: [
      Expanded(
        child: Column( children: [
          const Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_session.timeSlot!.startTime!.simpleTime())
        ],)
      ),
      Expanded(
        child: Column( children: [
          const Text("End Time", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_session.timeSlot!.endTime!.simpleTime())
        ],),
      )        
    ]);
  }

  Widget _locationWidget() {
    return Row(children: [
      Expanded(
        child: Column( children: [
          const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_session.room?.name ?? "")
        ],)
      ),
      Expanded(
        child: Column( children: [
          const Text("Format", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_session.format())
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
      Text(values.join(" - "))
    ]);
  }

}