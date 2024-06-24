import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/material.dart';

void showDialogWidget({required BuildContext context, required String title, required Widget content}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: textTheme(context).bodyMedium),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('확인', style: textTheme(context).bodySmall),
        )
      ],
    ),
  );
}