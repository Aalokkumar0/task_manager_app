import 'package:flutter/material.dart';

void main() {
  runApp(Bytevanta());
}
class Bytevanta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bytevanta",
      home: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title:Text('Bytevanta',style: TextStyle(fontSize: 30,fontWeight:FontWeight.w900),)
      ),
        body: Center(
          child: Text(
            "Welcome to Bytevanta"
          ),
        ),
      )
    );
  }
}
