import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

Widget textBtn({required BuildContext context, required String text, required void Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(text, style: textTheme(context).bodyMedium),
      ),
    ),
  );
}

Widget iconBtn({required Icon icon, required Color? backgroundColor, required void Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      width: 50,
      height: 50,
      child: icon,
    ),
  );
}