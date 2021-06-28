import 'package:curl_page/curl_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
      ),
      home: HomePage(),
    ),
  );
}

Widget _buildChild(String text, {Color color = Colors.teal}) => Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      color: color,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.red[100],
        body: Center(
          child: CurlPage(
            vertical: true,
            size: Size(300, 300),
            front: _buildChild('I am the FRONT'),
            back: _buildChild('I am the BACK' * 50, color: Colors.blueGrey),
          ),
        ),
      );
}
