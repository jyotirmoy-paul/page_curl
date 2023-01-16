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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildContainer(String text, {Color color = Colors.teal}) => Container(
        alignment: Alignment.center,
        color: color,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white.withAlpha(200),
        appBar: AppBar(
          title: const Text('Curling a page... virtually'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /* horizontal */
              PageCurl(
                vertical: false,
                back: _buildContainer('This is BACK'),
                front: _buildContainer(
                  'This is FRONT',
                  color: Colors.blueGrey,
                ),
                size: const Size(200, 150),
              ),
            ],
          ),
        ),
      );
}
