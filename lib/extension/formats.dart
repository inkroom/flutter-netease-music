import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/component/utils/time.dart';
import 'package:quiet/repository.dart';

extension ErrorFormat on BuildContext {
  /// human-readable error message
  String formattedError(dynamic error, {StackTrace? stacktrace}) {
    if (error is NotLoginException) {
      return strings.errorNotLogin;
    } else if (error is NetworkException) {
      return strings.networkNotAllow;
    } else if (error is LyricException) {
      return strings.noLyric;
    } else if (error is MusicException) {
      return strings.getPlayDetailFail;
    }
    if (stacktrace != null) {
      log('错误堆栈 $stacktrace');
    }
    return '$error';
  }
}

extension DurationFormat on Duration {
  String get timeStamp => getTimeStamp(inMilliseconds);
}
