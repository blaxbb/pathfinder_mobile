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
    var tracks = all.map((s) => s.track?.title).where((element) => element != null).cast<String>().toSet();
    var keywords = all.expand((s) => s.keywords()).toSet();
    var areas = all.expand((s) => s.interestAreas()).toSet();

    return ListView(
      children: [
        ...filterGroup("Regitration Level", regs, filter.registrationFilters),
        ...filterGroup("Track", tracks, filter.trackFilters),
        ...filterGroup("Keywords", keywords, filter.keywordFilters),
        ...filterGroup("Interest Areas", areas, filter.areaFilters)
      ],
    );
  }

  List<Widget> filterGroup(String title, Set<String> filters, Set<String> active) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(title, style: TextStyle(fontSize: 18),),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map(
          (e) => FilterChip(
            key: UniqueKey(),
            label: Text(e),
            selected: active.contains(e),
            selectedColor: Colors.blue[100],
            onSelected: (value) {
              setState(() {
                if(value) {
                  active.add(e);
                }
                else {
                  active.remove(e);
                }
              });
            }
          )
        ).toList()
      )
    ];
  }

}