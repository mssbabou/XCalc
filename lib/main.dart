import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const Calculator());

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
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
    List<String> lines = input.split("\n");

    List<String> ?results;
    ContextModel cm = ContextModel();
    lines.forEach((line) {
      //line = line.replaceAll(' ', '');
      if(line != ''){
        try {
          Parser p = Parser();
          Expression exp = p.parse(line);
          double res = exp.evaluate(EvaluationType.REAL, cm);
          print('$line = $res');
          results?.add('$res');          
        } catch (e) {
          print('$line = error');
          results?.add('');
        }
      } 
    });

    UpdateOutputs(lines, results!);
  }

  void UpdateOutputs(List<String> input, List<String> results){
    Outputs?.clear();
    for (var i = 0; i < input.length; i++) {
      Outputs?.add(Output(input: input[i], result: results[i]));
    }
  }

  List<Widget> ?Outputs;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          body: Column(
            children: [
              WindowTitleBarBox(
                child: Container(
                  color: Color.fromARGB(255, 50, 50, 50),
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
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Column(
                          children: Outputs!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
                        child: TextField(
                          onChanged: (value) {
                            Update(value);
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
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 72, 194, 173)
        ),
        children: <TextSpan>[
          TextSpan(text: input, style:  TextStyle(color: Color(0x00000000))),
          TextSpan(text: result)
        ]
      ),
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