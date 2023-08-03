import 'package:intl/intl.dart';
import 'package:pathfinder_mobile/Widgets/map_navigate_widget.dart';
import 'package:pathfinder_mobile/Widgets/session_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/session.dart';

class SessionWidget extends StatefulWidget {
  const SessionWidget(this._session, {Key? key}) : super(key: key);

  final Session _session;
  
  @override
  State<StatefulWidget> createState() => _SessionWidgetState(_session);
}

class _SessionWidgetState extends State<SessionWidget> {
  final Session _session;

  var tapped = false;

  _SessionWidgetState(this._session);

  @override
  Widget build(BuildContext context) {
      loadFavorited();
      return Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => setFavorited(),
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                tapped ? Icons.star : Icons.star_border,
                color: tapped ? Colors.yellow : Theme.of(context).textTheme.bodyMedium!.color,
                shadows: [
                  Shadow(color: tapped ? Colors.black : Colors.transparent, offset: const Offset(0,0), blurRadius: 2
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {Navigator.push(context, MaterialPageRoute(builder: ((context) => SessionDetailsWidget(_session))))},
              behavior: HitTestBehavior.translucent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _session.timeSlot?.startTime?.eventTime == null
                    ? const SizedBox.shrink()
                    : Padding(padding: const EdgeInsets.all(8), child: Text(_session.timeSlot!.startTime!.simpleTime(), style: const TextStyle(fontSize: 24))),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_session.title ?? "", style: const TextStyle(fontSize: 18),),
                      _session.Location == null
                          ? const SizedBox.shrink()
                          : Text(_session.Location!),
                      Text(_session.registrationLevelsReadable().join(" - ")),
                      Row(
                        children: [
                          _session.timeSlot?.endTime?.eventTime == null || _session.timeSlot?.startTime?.eventTime == null
                              ? const SizedBox.shrink()
                              : Flexible(child: Text(_session.timeSlot!.durationText())),                           
                        ],
                      )
                    ],
                  )
                  )
                ]
              )
            )
          ),
          _session.Location == null ?
            const SizedBox.shrink() :
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => navigateTo(),
              child: Container(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.map,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  shadows: [
                    Shadow(color: tapped ? Colors.black : Colors.transparent, offset: const Offset(0,0), blurRadius: 2
                    ),
                  ],
                ),
              ),
            ),
        ])
    );
  }

  Future<void> loadFavorited() async {
    final prefs = await SharedPreferences.getInstance();
    if(mounted)
    {
      setState(() {
        var id = _session.id;
        tapped = prefs.getBool("favorite_$id") ?? false;
      });
    }
  }

  Future<void> setFavorited() async {
    var state = !tapped;
    setState(() {
      tapped = state;
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

  Future<void> navigateTo() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MapNavigateWidget(_session.Location!))
    );
  }
}