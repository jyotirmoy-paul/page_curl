import 'package:flutter/material.dart';
import 'package:page_curl/page_curl.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page Curl Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  Widget _buildContainer(String text, {Color color = Colors.teal}) => Container(
        alignment: Alignment.center,
        color: color,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      );

  final double heightOfCards = 300;

  double get widthOfCards => 691 * heightOfCards / 1056;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white.withAlpha(200),
        appBar: AppBar(
          title: Text('Curling a page... virtually'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /* horizontal */
              PageCurl(
                back: _buildContainer('This is BACK'),
                front: _buildContainer(
                  'This is FRONT',
                  color: Colors.blueGrey,
                ),
                size: const Size(200, 150),
              ),

              /* vertical */
              PageCurl(
                vertical: true,
                back: Image.asset(
                  'assets/cards/front.png',
                  height: heightOfCards,
                  width: widthOfCards,
                ),
                front: Image.asset(
                  'assets/cards/back.png',
                  height: heightOfCards,
                  width: widthOfCards,
                ),
                size: Size(widthOfCards, heightOfCards),
              ),
            ],
          ),
        ),
      );
}
