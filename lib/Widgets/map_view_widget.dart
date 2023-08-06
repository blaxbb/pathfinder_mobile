import 'package:flutter/material.dart';

class MapViewWidget extends StatefulWidget {


  MapViewWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapViewWidgetState();

}

class MapViewWidgetState extends State<MapViewWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
      ),
      body: ListView (
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InteractiveViewer(
                      panEnabled: false,
                      minScale: .1,
                      maxScale: 4,
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width * .95)),
                          child: CustomPaint(
                              child: Image.asset("assets/maps/map_level_1_2023.jpg", fit: BoxFit.fill),
                            ),
                        ),
                      ),
                    ),
          ),
                  SizedBox.fromSize(size: Size(0, 32),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InteractiveViewer(
                      panEnabled: false,
                      minScale: .1,
                      maxScale: 4,
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width * .95)),
                          child: CustomPaint(
                              child: Image.asset("assets/maps/map_level_2_2023.jpg", fit: BoxFit.fill),
                            ),
                        ),
                      ),
                    ),
          )                  
        ],
      ),
    );
  }

}