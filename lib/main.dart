import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String displayText = '0';
  String displaySecondNumber = '0';
  bool isFirstNumber = true;
  int firstNumber = 0;
  int secondNumber = 0;
  static const int maxDisplayLength = 8;
  late String currentOperator;

  final operators = {
    '+': (num a, num b) => a + b,
    '-': (num a, num b) => a - b,
    '×': (num a, num b) => a * b,
    '÷': (num a, num b) => a / b,
  };

  void addNumber(int number) {
    if (displayText.length >= maxDisplayLength) return;

    if (displayText == '0') displayText = '';
    displayText += number.toString();

    try {
      isFirstNumber ? updateFirstNumber() : updateSecondNumber(number);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing number : $e');
      }
    }

    print('first : $firstNumber, second : $secondNumber');
    setState(() {});
  }

  void updateFirstNumber() {
    firstNumber = int.parse(displayText);
  }

  void updateSecondNumber(int number) {
    displaySecondNumber += number.toString();
    secondNumber = int.parse(displaySecondNumber);
  }

  void calculateWithOperator(String operator) {
    firstNumber = int.parse(displayText);
    displayText += operator;
    isFirstNumber = false;
    currentOperator = operator;
    setState(() {});
  }

  void resetCalculator() {
    setState(() {
      displayText = '0';
      displaySecondNumber = '0';
      isFirstNumber = true;
      firstNumber = 0;
      secondNumber = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              displayText,
              style: const TextStyle(
                fontSize: 40.0,
              ),
            ),
          ),
          buildButtonRow([
            createDigitButtonWithCallback('A/C', resetCalculator),
            createDigitButtonWithCallback('', null),
            createDigitButtonWithCallback('', null),
            createOperationButton('÷', () => calculateWithOperator('÷'))
          ]),
          buildButtonRow([
            createDigitButton(7),
            createDigitButton(8),
            createDigitButton(9),
            createOperationButton('×', () => calculateWithOperator('×'))
          ]),
          buildButtonRow([
            createDigitButton(4),
            createDigitButton(5),
            createDigitButton(6),
            createOperationButton('-', () => calculateWithOperator('-'))
          ]),
          buildButtonRow([
            createDigitButton(1),
            createDigitButton(2),
            createDigitButton(3),
            createOperationButton('+', () => calculateWithOperator('+'))
          ]),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (displayText.isNotEmpty) {
                      displayText =
                          displayText.substring(0, displayText.length - 1);
                      if (displayText.isEmpty) displayText = '0';
                    }
                    setState(() {});
                  },
                  child: const Text('C'),
                ),
              ),
              buildDigitButton(0),
              const DigitButton(
                buttonText: '.',
              ),
              OperationButton(
                operation: '=',
                onPressed: () {
                  if (operators.containsKey(currentOperator)) {
                    var result =
                        operators[currentOperator]!(firstNumber, secondNumber);
                    print('결과: $result');

                    if (result.toInt().toString().length > 8) {
                      displayText = 'ERR';
                    } else {
                      setState(() {
                        displayText = result.toString();
                      });
                      isFirstNumber = true;
                      firstNumber = 0;
                      secondNumber = 0;
                      displaySecondNumber = '0';
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row buildButtonRow(List<Widget> buttons) {
    return Row(
      children: buttons,
    );
  }

  Expanded buildDigitButton(int number) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          addNumber(number);
        },
        child: Text(
          number.toString(),
        ),
      ),
    );
  }

  Expanded createDigitButton(int number) {
    return createDigitButtonWithCallback(
        number.toString(), () => addNumber(number));
  }

  Expanded createDigitButtonWithCallback(String text, VoidCallback? onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }

  Expanded createOperationButton(String operation, VoidCallback? onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        child: Text(operation),
      ),
    );
  }
}

class OperationButton extends StatelessWidget {
  final String operation;
  final Function()? onPressed;

  const OperationButton({
    required this.operation,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        child: Text(operation),
      ),
    );
  }
}

class DigitButton extends StatelessWidget {
  final String buttonText;
  final Function()? onPressed;
  const DigitButton({super.key, required this.buttonText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(buttonText),
      ),
    );
  }
}

class InputButton extends StatelessWidget {
  const InputButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text('AC'),
        ),
      ),
    );
  }
}
