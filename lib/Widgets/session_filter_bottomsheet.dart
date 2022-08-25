import 'package:flutter/material.dart';

import '../Data/filter.dart';
import '../Data/session.dart';

class SessionFilterBottomsheet extends StatefulWidget {
  final List<Session> all;
  final Filter filter;

  const SessionFilterBottomsheet(this.all, this.filter, {Key? key}) : super(key: key);

  

  @override
  State<StatefulWidget> createState() => SessionFilterBottomsheetState(all, filter);

}

class SessionFilterBottomsheetState extends State {

  List<Session> all;
  Filter filter;

  SessionFilterBottomsheetState(this.all, this.filter);

  @override
  Widget build(BuildContext context) {

    var regs = all.expand((s) => s.registrationLevels()).toSet();

    return ListView(
      children: [
        const Text("Registration Levels"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: regs.map(
            (e) => FilterChip(
              label: Text(e),
              selected: filter.registrationFilters.contains(e),
              selectedColor: Colors.blueAccent,
              onSelected: (value) {
                setState(() {
                  if(value) {
                    filter.registrationFilters.add(e);
                  }
                  else {
                    filter.registrationFilters.remove(e);
                  }
                });
              }
            )
          ).toList()
        )
      ],
    );
  }

}