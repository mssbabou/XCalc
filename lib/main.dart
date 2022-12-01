import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';
import 'dart:core';
import 'dart:math' as math;

SavedSettings settings = SavedSettings('');
Map<String, dynamic> settingsMap = {};
bool autosave = true;

void main() {
  ReadSettings();

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

void ReadSettings() {
  // For Tesing "C:/Users/mssba/Desktop/Programming1/Code/Better Calculator/xcalc/build/windows/runner/Release/save.json"
  //final File file = File("save.json");
  final File file = File("C:/Users/mssba/Desktop/Programming1/Code/Better Calculator/xcalc/build/windows/runner/Release/save.json");
  settingsMap = jsonDecode(file.readAsStringSync());
  settings = SavedSettings.fromJson(settingsMap);
  
  if(settings.input == ''){
    autosave = false;
  }
}

void WriteSettings() {
  if(!autosave){
    settings.input = '';
  }

  settingsMap = settings.toJson();
  // For Tesing "C:/Users/mssba/Desktop/Programming1/Code/Better Calculator/xcalc/build/windows/runner/Release/save.json"
  //final File file = File("save.json");
  final File file = File("C:/Users/mssba/Desktop/Programming1/Code/Better Calculator/xcalc/build/windows/runner/Release/save.json");
  file.writeAsStringSync(jsonEncode(settingsMap));
}

class SavedSettings {
  String input = '';

  SavedSettings(this.input);

  SavedSettings.fromJson(Map<String, dynamic> json)
    : input  = json['input'];

  Map<String, dynamic> toJson() => {
        'input' : input
      };

}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  ContextModel cm = ContextModel();

  @override
  void initState() {
    Update(settings.input);
    super.initState();
  }

  

  void Update(String input) {
    settings.input = input;
    Outputs.clear();
    List<String> lines = input.split("\n");

    BlankContext();

    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Check if line is valid equation
      String result = CalculateExpression(line);
      if (result == '') {
        result = GetVarible(line);
      }

      Outputs.add(Output(input: line, result: result));
    }
  }

  void BlankContext() {
    cm = ContextModel();
    cm.bindVariable(Variable('pi'), Number(math.pi));
    cm.bindVariable(Variable('PI'), Number(math.pi));
  }

  String CalculateExpression(String line) {
    String result = '';

    try {
      Parser p = Parser();
      Expression exp = p.parse(line);
      result = exp.evaluate(EvaluationType.REAL, cm).toString();
      //Decimal res = exp.evaluate(EvaluationType.REAL, cm);
      result = removePoint0(result);
      //print(res);
    } catch (e) {
      result = '';
    }

    return result;
  }

  String GetVarible(String _line) {
    if (!_line.contains('=')) {
      return '';
    }

    String line = _line.trim();
    List<String> expressions = line.split('=');

    if (expressions.length != 2) {
      return '';
    }

    expressions[0] = expressions[0].trim();
    expressions[1] = expressions[1].trim();

    if (!RegExp(r'^[a-zA-Z]+[a-z]*$').hasMatch(expressions[0])) {
      return '';
    }

    String oldExp = expressions[1];
    expressions[1] = CalculateExpression(expressions[1]);

    if (expressions[1] == '') {
      return '';
    }

    Expression exp = Parser().parse(expressions[1]);
    cm.bindVariable(Variable(expressions[0]), exp);

    if (oldExp == expressions[1]) {
      return '';
    } else {
      return expressions[1];
    }
  }

  String removeDecimals(String input, int cutOff) {
    String newInput = '';
    int zeros = 0;
    for (var i = 0; i < input.length; i++) {
      if (input[i] == '0') {
        zeros++;
      } else {
        zeros = 0;
        String zeroString = '';
        for (var i = 0; i < zeros; i++) {
          zeroString += '0';
        }
        newInput = zeroString + newInput + input[i];
      }

      if (zeros >= cutOff - 1) {
        return newInput;
      }
    }

    return input;
  }

  String removePoint0(dynamic num) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return num.toString().replaceAll(regex, '');
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  List<Widget> Outputs = [];
  //bool saveButton = false;
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
                    AutoSaveButton(),
                    Expanded(child: MoveWindow()),
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
                      child: TextFormField(
                        initialValue: settings.input,
                        onChanged: (value) {
                          Update(value);
                          setState(() {});
                        },
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 20),
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

  Output({super.key, required this.input, required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IgnorePointer(
          child: Text(
            input,
            style: const TextStyle(
                fontSize: 20, color: Color.fromARGB(0, 0, 0, 0)),
          ),
        ),
        IgnorePointer(
          child: Text(
            result == '' ? '' : ' = ',
            style: const TextStyle(
                fontSize: 20, color: Color.fromARGB(255, 72, 194, 173)),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: result));
              },
              style: TextButton.styleFrom(
                  minimumSize: Size.zero, padding: const EdgeInsets.all(1.0)),
              child: Text(
                result,
                style: const TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 72, 194, 173)),
              )),
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
        MinimizeWindowButton(
            colors: WindowButtonColors(
                iconNormal: const Color.fromARGB(255, 255, 255, 255))),
        MaximizeWindowButton(
            colors: WindowButtonColors(
                iconNormal: const Color.fromARGB(255, 255, 255, 255))),
        CloseWindowButton(
            colors: WindowButtonColors(iconNormal: const Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              WriteSettings();
              appWindow.close();    
            },
        ),
      ],
    );
  }
}

class AutoSaveButton extends StatefulWidget {
  AutoSaveButton({super.key});

  static const Color onColor = Color.fromARGB(255, 30, 189, 229);
  static const Color offColor = Color.fromARGB(255, 190, 190, 190);

  @override
  State<AutoSaveButton> createState() => _AutoSaveButtonState();
}

class _AutoSaveButtonState extends State<AutoSaveButton> {
  Color currentColor = autosave ? AutoSaveButton.onColor : AutoSaveButton.offColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (() {
      if(autosave){
        autosave = false;
        currentColor = AutoSaveButton.offColor;
      }else{
        autosave = true;
        currentColor = AutoSaveButton.onColor;
      }
      setState(() {});
      print(autosave);
    }), 
      tooltip: 'Autosave',
      padding: EdgeInsets.zero,
      splashRadius: 15,
      iconSize: 20,
      //hoverColor: Color.fromARGB(255, 255, 255, 255),
      color: currentColor,
      icon: Icon(Icons.save_outlined)
    );
  }
}