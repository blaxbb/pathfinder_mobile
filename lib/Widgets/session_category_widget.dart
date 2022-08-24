
import 'package:pathfinder_mobile/Widgets/session_widget.dart';
import 'package:flutter/material.dart';

import '../Data/session.dart';

class SessionCategoryWidget extends StatelessWidget {
  const SessionCategoryWidget(this.sessions, {Key? key, this.title}) : super(key: key);
  
  final List<Session> sessions;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all()
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title == null ? const SizedBox.shrink() : Text(title!, style: const TextStyle(fontSize: 24),),
          ...sessions.map((s) => SessionWidget(s)).toList()
        ]
      ),
    );
  }
}