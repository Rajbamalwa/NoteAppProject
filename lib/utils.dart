import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class Utils {
  static void flushBarError(String msg, BuildContext context) {
    showFlushbar(
        context: context,
        flushbar: Flushbar(
          backgroundColor: Colors.blueGrey,
          message: msg,
          duration: const Duration(seconds: 3),
        )..show(context));
  }
}
