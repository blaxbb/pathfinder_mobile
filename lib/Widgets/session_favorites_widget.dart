import 'package:flutter/material.dart';
import 'package:pathfinder_mobile/Widgets/session_index_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/session.dart';

class SessionFavoritesWidget extends StatefulWidget {
  const SessionFavoritesWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SessionFavoriteWidgetState();
}

class SessionFavoriteWidgetState extends SessionIndexWidgetState {
  @override
  String title() => "My Favorites";
  
  @override
  Widget getSessionIndexList() {

    return FutureBuilder<List<Session>>(
      future: filterFavorited(all),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return const CircularProgressIndicator();
        }
        if(snapshot.hasData) {
          return SessionIndexList(snapshot.data!, filterDate, filter);
        }

        return const SizedBox.shrink();
      }
    );
  }

  Future<List<Session>> filterFavorited(List<Session> sessions) async {
    final result = <Session>[];
    await Future.forEach<Session>(sessions, (session) async {
      if(await getFavorited(session)){
        result.add(session);
      }
    });
    return result;
  }

  Future<bool> getFavorited(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("favorite_${session.id}") ?? false;
  }
}