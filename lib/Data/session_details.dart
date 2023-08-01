import 'package:pathfinder_mobile/Data/presentation.dart';
import 'package:pathfinder_mobile/Data/session.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parse;

class SessionDetails {
  late Session session;
  late List<Presentation> presentations = [];
  late String? description;

 static Future<SessionDetails?> Get(Session _session) async {
  var retVal = new SessionDetails();

  if(_session.description != null && _session.description!.isNotEmpty) {
    return null;
  }

  if(_session.Url?.isNotEmpty ?? false) {

    var uri = Uri.parse("https://s2023.siggraph.org${_session.Url!}");
    final http.Response response = await http.get(uri);
    if(response.statusCode >= 200 && response.statusCode < 300)
    {
      var body = parse.parse(response.body);

      var presentationElements = body.querySelectorAll('tr.agenda-item');
      retVal.presentations = presentationElements.map((p) => Presentation.FromElement(p)).toList();

      retVal.description = body.querySelector('.info-section .abstract')?.innerHtml;

      // var presenterElements = body.querySelectorAll('.presenting');
      // presentationElements.map((p) => )

      return retVal;

    }
  }

  return null;
 }
}