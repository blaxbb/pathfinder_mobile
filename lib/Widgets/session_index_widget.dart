import 'dart:convert';

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

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(padding: EdgeInsets.all(8), child: Text("Monday")),
                    onTap: () => setState(() {
                     filterDate = 8;
                    }),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(padding: EdgeInsets.all(8), child: Text("Tuesday")),
                    onTap: () => setState(() {
                     filterDate = 9;
                    }),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(padding: EdgeInsets.all(8), child: Text("Wednesday")),
                    onTap: () => setState(() {
                     filterDate = 10;
                    }),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(padding: EdgeInsets.all(8), child: Text("Thursday")),
                    onTap: () => setState(() {
                     filterDate = 11;
                    }),
                  ),                                    
                ],
              ),
              _SessionIndexList(all, filterDate)
            ],
          );
        },
      )
    );
  }
}

class _SessionIndexList extends StatelessWidget{

  final List<Session> _all;
  final int filterDate;

  const _SessionIndexList(this._all, this.filterDate);

  List<Session> _filterList()
  {
    return _all.where((element) => element.timeSlot!.startTime!.uTC!.day == filterDate).toList();
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