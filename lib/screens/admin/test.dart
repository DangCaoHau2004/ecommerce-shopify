import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Color pickerColor = Color(4282025408);
  Color currentColor = Colors.blue;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              print("color ${int.parse(pickerColor.toHexString(), radix: 16)}");
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Color Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selected Color:"),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: currentColor,
                border:
                    Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: showColorPickerDialog,
              child: const Text("Pick a Color"),
            ),
          ],
        ),
      ),
    );
  }
}
