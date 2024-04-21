// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark(),
      home: CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _output = '0';
  double _num1 = 0.0;
  double _num2 = 0.0;
  String _operand = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _output = '0';
        _num1 = 0.0;
        _num2 = 0.0;
        _operand = '';
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '/') {
        _num1 = double.parse(_output);
        _operand = buttonText;
        _output = '0';
      } else if (buttonText == '=') {
        _num2 = double.parse(_output);
        if (_operand == '+') {
          _output = (_num1 + _num2).toString();
        } else if (_operand == '-') {
          _output = (_num1 - _num2).toString();
        } else if (_operand == '×') {
          _output = (_num1 * _num2).toString();
        } else if (_operand == '/') {
          _output = (_num2 != 0) ? (_num1 / _num2).toString() : 'Error';
        }
        _num1 = 0.0;
        _num2 = 0.0;
        _operand = '';
      } else {
        _output = (_output == '0') ? buttonText : _output + buttonText;
      }
    });
  }

  Widget _buildButton(String label, Color color, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: color,
            padding: EdgeInsets.all(24),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('7', Colors.grey.shade800, 1),
              _buildButton('8', Colors.grey.shade800, 1),
              _buildButton('9', Colors.grey.shade800, 1),
              _buildButton('×', Colors.orange.shade700, 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('4', Colors.grey.shade800, 1),
              _buildButton('5', Colors.grey.shade800, 1),
              _buildButton('6', Colors.grey.shade800, 1),
              _buildButton('-', Colors.orange.shade700, 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('1', Colors.grey.shade800, 1),
              _buildButton('2', Colors.grey.shade800, 1),
              _buildButton('3', Colors.grey.shade800, 1),
              _buildButton('+', Colors.orange.shade700, 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('C', Colors.grey.shade800, 1),
              _buildButton('0', Colors.grey.shade800, 1),
              _buildButton('/', Colors.orange.shade700, 1),
              _buildButton('=', Colors.orange.shade700, 1),
            ],
          ),
        ],
      ),
    );
  }
}
