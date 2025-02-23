import 'package:flutter/material.dart';

List<Widget> allColorOfProduct(
    context, List<int> hex, double height, double width) {
  List<Widget> colors = [];
  if (hex.length == 1) {
    colors.add(
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary, width: 0.2),
          color: Color(
            hex[0],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
    return colors;
  }
  for (var i = 0; i < hex.length; i++) {
    colors.add(
      Row(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 0.2),
              color: Color(
                hex[i],
              ),
              shape: BoxShape.circle,
            ),
          ),
          if (i != hex.length - 1)
            const SizedBox(
              width: 4,
            ),
        ],
      ),
    );
  }
  return colors;
}
