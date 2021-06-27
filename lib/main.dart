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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.red[100],
        // appBar: AppBar(title: Text("Curl Page")),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CurlPage(
              size: MediaQuery.of(context).size,
              front: Container(
                alignment: Alignment.center,
                color: Colors.teal,
                child: Text(
                  "This is my cool sentence",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              back: Text('This is a pretty large hidden text, out there' * 20),
            ),
          ),
        ),
      );
}
