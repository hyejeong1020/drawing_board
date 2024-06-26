import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/material.dart';

Future showDialogWidget({required BuildContext context, required String title, required Widget content}) {
  print('dialog');
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: textTheme(context).bodyMedium),
      content: content,
      actions: [
        SizedBox(
          width: ssW(context),
          height: 50,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blueGrey.withOpacity(0.1)),
              shape: WidgetStatePropertyAll(
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)),
              ),
            ),
            child: Text('확인', style: textTheme(context).bodyMedium),
          ),
        ),
      ],
    ),
  );
}