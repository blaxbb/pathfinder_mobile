import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pathfinder_mobile/Widgets/session_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/session.dart';

class SessionIndexWidget extends StatefulWidget {
  const SessionIndexWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SessionIndexWidgetState();
}

class SessionIndexWidgetState extends State {

  var filterDate = 8;
  List<Session> all = List.empty();

  Future<List<Session>> readJson() async {
    final String response = await rootBundle.loadString('assets/sessions.json');
    final Iterable data = await jsonDecode(response);
    all = List<Session>.from(data.map((e) => Session.fromJson(e)));
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Session List")),
      body: FutureBuilder<List<Session>>(
        future: readJson(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          else if(snapshot.hasError)
          {
            return const Text("Error loading session info");
          }

          final start = DateTime(2022, 8, 8, 7);
          final end = DateTime(2022, 8, 11, 7);

          return Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: _dayButtons(start, end).toList(),
              ),
              _SessionIndexList(all, filterDate)
            ],
          );
        },
      )
    );
  }

Iterable<Widget> _dayButtons(DateTime start, DateTime end) sync*{

    var days = end.difference(start).inDays;
    for(int i = 0; i <= days; i++) {
      var day = start.add(Duration(days: i));
      yield TextButton(
        onPressed: () {
          setState(() {
            filterDate = day.day;
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: filterDate == day.day ? Theme.of(context).backgroundColor : Theme.of(context).highlightColor,
          padding: const EdgeInsets.all(12),
        ),
        child: Column(children: [Text(day.day.toString()), Text(DateFormat('EEEE').format(day))])
      );
    }

  }
  
}

class _SessionIndexList extends StatelessWidget{

  final List<Session> _all;
  final int filterDate;

  const _SessionIndexList(this._all, this.filterDate);

  List<Session> _filterList()
  {
    var ret = _all.where((element) => element.timeSlot!.startTime!.eventTime!.add(const Duration(hours: -7)).day == filterDate).toList();
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