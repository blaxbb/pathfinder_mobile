import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;

import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart';
import 'package:pathfinder_mobile/Widgets/session_filter_bottomsheet.dart';
import 'package:pathfinder_mobile/Widgets/session_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/filter.dart';
import '../Data/session.dart';

class SessionIndexWidget extends StatefulWidget {
  const SessionIndexWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SessionIndexWidgetState();
}

class SessionIndexWidgetState extends State {

  var displayFilter = false;
  var filterDate = 6;
  List<Session> all = List.empty();
  var regFilters = <String>{};
  var filter = Filter();
  final controller = TextEditingController();

  String title() => "Session List";

  Future<List<Session>> readWeb() async {
    log("http");
    final http.Response response = await http.get(Uri.parse('https://s2023.siggraph.org/wp-content/linklings_snippets/wp_program_view_all_2023-08-${filterDate.toString().padLeft(2, '0')}.txt'));
    if(response.statusCode >= 200 && response.statusCode < 300) {
      final String body = response.body;
      var doc = parse.parse(response.body);
      var items = doc.querySelectorAll("body > table > tbody > .agenda-item");
      var web = List<Session>.from(items.map((e) => Session.fromHtml(e)));
      all = web;
      return web;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title()),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                displayFilter = !displayFilter;
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return SessionFilterBottomsheet(all, filter);
                    });
                  },
                ).whenComplete(() => setState(() {
                  
                },));
              });
            },
            icon: Icon(Icons.search))
        ],
      ),
      body: FutureBuilder<List<Session>>(
        future: readWeb(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError)
          {
            return const Text("Error loading session info");
          }

          final start = DateTime(2023, 8, 6, 7);
          final end = DateTime(2023, 8, 10, 7);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 4,
                  children: _dayButtons(start, end).toList(),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  filter.search?.isEmpty ?? true ?
                    SizedBox.shrink() :
                    FilterChip(
                      label: Text(filter.search ?? ""),
                      onSelected: (value) => setState(() {
                        filter.search = "";
                      }),
                    ),
                  ...filterChip(filter.registrationFilters),
                  ...filterChip(filter.trackFilters),
                  ...filterChip(filter.keywordFilters),
                  ...filterChip(filter.areaFilters),
                ],
              ),
              const Divider(),
              getSessionIndexList()
            ],
          );
        },
      ),
    );
  }

  Widget getSessionIndexList() {
    return SessionIndexList(all, filterDate, filter);
  }


  Iterable<FilterChip> filterChip (Set<String> filters) {
    return <FilterChip>[
      ...filters.map(
        (f) => FilterChip(
          label: Text(f),
          selected: true,
          onSelected: ((value) {
            setState(() => filters.remove(f));
          })
        )
      )
    ];
  }

  Iterable<Widget> _dayButtons(DateTime start, DateTime end) sync*{

    var days = end.difference(start).inDays;
    for(int i = 0; i <= days; i++) {
      var day = start.add(Duration(days: i));
      yield TextButton(
        onPressed: () {
          setState(() {
            filterDate = day.day;
            all = [];
            // readWeb();
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: filterDate == day.day ? Theme.of(context).backgroundColor : Theme.of(context).highlightColor,
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          children: [
            Text(day.day.toString(), style: Theme.of(context).textTheme.bodyMedium),
            Text(DateFormat('EEEE').format(day), style: Theme.of(context).textTheme.bodyMedium)
          ]
        )
      );
    }
  }
}

class SessionIndexList extends StatelessWidget{

  final List<Session> _all;
  final int filterDate;
  final Filter filter;

  const SessionIndexList(this._all, this.filterDate, this.filter, {Key? key}) : super(key: key);

  List<Session> _filterList()
  {
    if(filter.search?.isNotEmpty ?? false)
    {
      var fuzz = extractTop<Session>(query: filter.search!, choices: _all, limit: 20, getter: (obj) => obj.title!,);
      // var fuzzBody = extractTop<Session>(query: filter.search!, choices: _all, limit: 20, getter: (obj) => obj.description!);
      // fuzz.addAll(fuzzBody);

      var duplicate = <int>{};
      fuzz.retainWhere((element) => duplicate.add(element.index));

      fuzz.sort((a,b) => b.score.compareTo(a.score));
      return fuzz.map((e) => e.choice).toList();
    }

    var ret = _all
      .where((element) => element.enabled ?? false)
      .where((element) => element.timeSlot!.startTime!.eventTime!.day == filterDate)
      .where((element) => filter.registrationFilters.isEmpty || filter.registrationFilters.any((f) => element.registrationLevels().any((element) => element.name == f)))
      .where((element) => filter.keywordFilters.isEmpty || filter.keywordFilters.any((f) => element.keywords().any((element) => element.name == f)))
      .where((element) => filter.areaFilters.isEmpty || filter.areaFilters.any((f) => element.interestAreas().any((element) => element.name == f)))
      .toList();
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var filtered = _filterList();

    return Expanded(key: UniqueKey(), child: ListView.separated(
      itemBuilder: (context, index) {
        return SessionWidget(filtered[index]);
      }, 
      separatorBuilder: (context, index) => const Divider(),
      itemCount: filtered.length
    ));
  }

}