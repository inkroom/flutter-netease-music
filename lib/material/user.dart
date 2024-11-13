import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quiet/component.dart';

Future<bool> showNeedLoginToast(BuildContext context) async {
  final completer = Completer();
  showToastWidget(
      Opacity(
          opacity: 0.5,
          child: _Toast(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.strings.needLogin),
              InkWell(
                onTap: () async {
                  dismissAllToast();
                  final loginResult =
                      await Navigator.pushNamed(context, pageLogin);
                  completer.complete(loginResult == true);
                },
                child: Text(
                  context.strings.toLoginPage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.blue),
                ),
              )
            ],
          ))),
      duration: const Duration(milliseconds: 2000));
  return await (completer.future as FutureOr<bool>);
}

class _Toast extends StatelessWidget {
  const _Toast({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText1!,
          child: Align(
            alignment: const Alignment(0, 0.5),
            child: Material(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
