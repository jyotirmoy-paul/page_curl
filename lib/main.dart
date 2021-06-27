import 'package:curl_page/curl_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const String _imageFront =
    'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/8a09db0a-17dd-49ff-952a-9cf59fea92bb/d76951d-e0b5c3a4-b717-43d0-87de-e06275da14d0.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzhhMDlkYjBhLTE3ZGQtNDlmZi05NTJhLTljZjU5ZmVhOTJiYlwvZDc2OTUxZC1lMGI1YzNhNC1iNzE3LTQzZDAtODdkZS1lMDYyNzVkYTE0ZDAucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.hmLJp2HbuhlQa8ttYlEyBeQXcEx4oL269wmggBD9mCc';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        accentColor: Colors.pinkAccent,
      ),
      home: HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Curl Page")),
        body: Center(
          child: Container(
            height: 600,
            width: 350,
            child: CurlPage(
              front: Container(
                alignment: Alignment.center,
                color: Colors.green,
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
