import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oryn/index.dart';

void copyToClipboard({
  required BuildContext context,
  required String text,
  String? displayText,
}) {
  Clipboard.setData(
    ClipboardData(text: text),
  );
  ShowSnackBar().showSnackBar(
    context,
    displayText ?? CustomLocalizations.of(context).copied,
  );
}
