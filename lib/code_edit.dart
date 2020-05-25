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

  bool hasErrors(res) =>
    res["message"] == "successful" && !(res["res"]["stderr"] == "");
    
  
  @override
  Widget build(BuildContext context) {
    var showBottomSheet = (Map<String, dynamic> res) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    // Heading
                    
                    hasErrors(res)
                    ? Text('Errors', style: TextStyle(fontSize: 24, color: Colors.redAccent))
                    : Text('Output', style: TextStyle(fontSize: 24)),
                    
                    Divider(),
                    SizedBox(height: 6),

                    hasErrors(res)
                    ? Text(res["res"]["stderr"], style: TextStyle(fontSize: 18))
                    : Text(res["res"]["stdout"], style: TextStyle(fontSize: 18))
                    // Body
                  ],
                ),
              ),
            ),
          );
        }
      );
    };

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
                    httpService.compileAndExecute(textEditingController.text, '')
                    .then((res) => showBottomSheet(res));
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