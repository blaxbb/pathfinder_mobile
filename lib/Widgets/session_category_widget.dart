
import 'package:pathfinder_mobile/Widgets/session_widget.dart';
import 'package:flutter/material.dart';

import '../Data/session.dart';

class SessionCategoryWidget extends StatelessWidget {
  const SessionCategoryWidget(this.sessions, {Key? key, this.title, this.subtitle}) : super(key: key);
  
  final List<Session> sessions;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).dialogBackgroundColor
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              title == null ? const SizedBox.shrink() : Flexible(child: Text(title!, style: const TextStyle(fontSize: 28))),
              subtitle == null ? const SizedBox.shrink() : Flexible(child: Text(subtitle!)),
            ],),
          ),
          ...sessions.isNotEmpty ? [...sessions.map((s) => SessionWidget(s)).toList()] : [const Padding(padding: EdgeInsets.all(16), child: Text("No events found"))]
        ]
      ),
    );
  }
}