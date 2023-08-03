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
  final controller = TextEditingController();

  SessionFilterBottomsheetState(this.all, this.filter);


  @override
  Widget build(BuildContext context) {

    var regs = all.expand((s) => s.registrationLevels().where((e) => e != null).toSet().map((e) => e.name)).toSet();
    var keywords = all.expand((s) => s.keywords().where((e) => e != null).toSet().map((e) => e.name)).toSet();
    var areas = all.expand((s) => s.interestAreas().where((e) => e != null).toSet().map((e) => e.name)).toSet();

    controller.text = filter.search ?? "";

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            onChanged: (value) { filter.search = value; },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Search",
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    filter.search = "";
                  });
                },
              )
            ),
          ),
        ),
        ...filterGroup("Registration Level", regs.cast<String>(), filter.registrationFilters),
        ...filterGroup("Keywords", keywords.cast<String>(), filter.keywordFilters),
        ...filterGroup("Interest Areas", areas.cast<String>(), filter.areaFilters),
        SizedBox.fromSize(size: const Size(0, 16),)
      ],
    );
  }

  List<Widget> filterGroup(String title, Set<String> filters, Set<String> active) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(title, style: const TextStyle(fontSize: 18),),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Wrap(
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
        ),
      )
    ];
  }

}