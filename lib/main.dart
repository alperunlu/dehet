import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  String result = '';

Future<int> searchGoogle(String query) async {
  try {
    final encodedQuery = Uri.encodeQueryComponent(query);
    //final uri = Uri.parse('https://cors-anywhere.herokuapp.com/https://www.google.com/search?q=%22$encodedQuery%22');
    final uri = Uri.parse('https://corsproxy.io/?https://www.google.com/search?q=%22$encodedQuery%22');
    //final uri = Uri.parse('https://www.google.com/search?q=%22$encodedQuery%22');
    print("searchGoogle started: $query"); // Debug
    print("URL: ${uri}");
    var response = await http.get(uri);
    print("HTTP status code: ${response.statusCode}"); // Debug

    if (response.statusCode == 200) {
      var document = parse(response.body);
      print("HTML content parsed"); // Debug

      var resultStats = document.getElementById('result-stats');
      if (resultStats != null) {
        var resultsText = resultStats.text;
        print("Search content: $resultsText"); // Debug

        var resultsNumber = int.tryParse(
          resultsText.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        print("Search count: $resultsNumber"); // Debug
        return resultsNumber ?? 0;
      } else {
        print("Nothing found."); // Debug
        return 0;
      }
    } else {
      print("HTTP request failed: ${response.statusCode}"); // Debug
      return 0;
    }
  } catch (e) {
    print("HTTP request failed: $e"); // Debug
    return 0;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('de OR het')),
      body: Column(
        children: <Widget>[
          TextField(
            controller: myController,
          ),
          ElevatedButton(
            child: Text('Ask'),
            onPressed: () async {
              print("Running..."); // Debug
              final word = myController.text;
              final deResult = await searchGoogle('de $word');
              final hetResult = await searchGoogle('het $word');
              print("de result: $deResult, het result: $hetResult"); // Debug

              setState(() {
                if (deResult > hetResult) {
                  result = 'de $word';
                } else {
                  result = 'het $word';
                }
                print("Result updated: $result"); // Debug
              });
            },
          ),
          Text('Result: $result',
           style: TextStyle(
    fontSize: 18.0, 
    fontWeight: FontWeight.bold,),)
        ],
     ),
);
}
}