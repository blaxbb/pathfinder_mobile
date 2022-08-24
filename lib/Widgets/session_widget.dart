import 'package:pathfinder_mobile/Widgets/session_details_widget.dart';
import 'package:flutter/material.dart';

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
      return Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => {
              setState(() {
                tapped = !tapped;
              },)
            },
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                tapped ? Icons.star : Icons.star_border,
                color: tapped ? Colors.yellow : Colors.black,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_session.title ?? "", style: const TextStyle(fontSize: 18),),
                  _session.room == null
                      ? const SizedBox.shrink()
                      : Text(_session.room!.name!),
                  Row(
                    children: [
                      _session.timeSlot?.startTime?.eventTime == null
                          ? const SizedBox.shrink()
                          : Expanded(child: Text(_session.timeSlot!.startTime!.simpleTime())),
                      const SizedBox(width: 8),
                      _session.timeSlot?.endTime?.eventTime == null
                          ? const SizedBox.shrink()
                          : Expanded(child: Text(_session.timeSlot!.endTime!.simpleTime())),
                    ],
                  )
                ],
              )
            )
          ),
        ])
    );
  }
}