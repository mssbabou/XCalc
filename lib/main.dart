import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const Calculator());

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "XCalc";
    appWindow.show();
  });
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  @override
  void initState() {
    super.initState();
  }

  void Update(String input){
    Outputs.clear();
    List<String> lines = input.split("\n");

    ContextModel cm = ContextModel();
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      String res = '';
      double num = 0;
        try {
          Parser p = Parser();
          Expression exp = p.parse(line);
          num = exp.evaluate(EvaluationType.REAL, cm);
          res = num.toStringAsFixed(7);
          res = removePoint0(res);     
        } catch (e) {
          res = '';
        }
        Outputs.add(Output(input: line, result: res));
    }
  }

  String removeDecimals(String input, int cutOff){
    String newInput = '';
    int zeros = 0;
    for (var i = 0; i < input.length; i++) {
      if(input[i] == '0'){
        zeros++;
      }else{
        zeros = 0;
        String zeroString = '';
        for (var i = 0; i < zeros; i++) {
          zeroString += '0';
        }
        newInput = zeroString + newInput + input[i];
      }

      if(zeros >= cutOff-1){
        return newInput;
      }

    }

    return input;
  }

  String removePoint0(dynamic num) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return num.toString().replaceAll(regex, '');
  }

  List<Widget> Outputs = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          body: Column(
            children: [
              WindowTitleBarBox(
                child: Container(
                  color: const Color.fromARGB(255, 50, 50, 50),
                  child: Row(
                    children: [
                      Expanded(
                        child: MoveWindow()
                      ),
                      const WindowButtons()
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
                        child: TextField(
                          onChanged: (value) {
                            Update(value);
                            setState(() {});
                          },
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20
                            ),
                          
                          decoration: const InputDecoration.collapsed(
                            hintText: '',
                          ),
                        ),
                      ),
                      Column(
                        children: Outputs,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class Output extends StatelessWidget {
  String input;
  String result;

  Output({
  super.key, 
  required this.input, 
  required this.result
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IgnorePointer(
          child: Text(
            input,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(0, 0, 0, 0)
            ),
          ),
        ),
        IgnorePointer(
          child: Text(
            result == ''? '' : ' = ',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 72, 194, 173)
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: TextButton(
            onPressed: () async{
              await Clipboard.setData(ClipboardData(text: result));
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.all(1.0)
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 72, 194, 173)              
              ),
            )
          ),
        ),
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: WindowButtonColors(iconNormal: Color.fromARGB(255, 255, 255, 255))),
        MaximizeWindowButton(colors: WindowButtonColors(iconNormal: Color.fromARGB(255, 255, 255, 255))),
        CloseWindowButton(colors: WindowButtonColors(iconNormal: Color.fromARGB(255, 255, 255, 255)))
      ],
    );
  }
}