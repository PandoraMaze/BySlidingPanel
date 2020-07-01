import 'package:by_sliding_panel/by_sliding_panel.dart';
import 'package:flutter/material.dart';

import 'base/page_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pandora Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'BySlidingPanel Demo'),
    );
  }
}

class MyHomePage extends BasePageWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BasePageState<MyHomePage> {
  final double rightWidth = 72;
  final double leftWidth = 50;

  var _sliderState = SlideState.CLOSE;

  @override
  String getTitle() {
    return 'SlidingPanel Demo';
  }

  @override
  buildBody() => Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: BySlidingPanel(
          state: _sliderState,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('TRY TO SLIDE', style: TextStyle(color: Colors.white))],
            ),
            color: Colors.blue,
          ),
          leftButtonWidth: leftWidth,
          leftButtons: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: leftWidth,
                color: Colors.teal,
                child: Center(
                  child: Text('H', style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () => toast('Head Button Clicked'),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: leftWidth,
                color: Colors.green,
                child: Center(
                  child: Text('N', style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () => toast('Neck Button Clicked'),
            ),
          ],
          rightButtonWidth: rightWidth,
          rightButtons: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: rightWidth,
                color: Colors.red,
                child: Center(
                  child: Text('BEHIND', style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () => toast('Right Button Clicked'),
            ),
          ],
          onItemTap: () => toast('Content Clicked'),
        ),
      );
}
