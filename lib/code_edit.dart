import 'package:code_executor/service.dart';
import 'package:flutter/material.dart';

class CodeEdit extends StatefulWidget {
  final String code;
  final int maxLines;
  CodeEdit({
    this.code,
    this.maxLines
  });
  @override
  _CodeEdit createState() => _CodeEdit();
}

class _CodeEdit extends State<CodeEdit> {

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.code;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'CODE EDITOR',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Card(
                color: Colors.black,
                child: TextField(
                  style: TextStyle(color: Colors.greenAccent),
                  decoration: InputDecoration(
                    border: OutlineInputBorder()
                  ),
                  maxLines: 12,
                  controller: textEditingController,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: RaisedButton(
                  color: Colors.blueGrey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('COMPILE & EXECUTE', style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  onPressed: (){
                    httpService.compileAndExecute(textEditingController.text, '');
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}