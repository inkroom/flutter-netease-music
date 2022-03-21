import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

import '../navigation/common/player/lyric.dart';

final lyricProvider =
    FutureProvider.family<LyricContent?, int>((ref, id) async {
  final lyric = await networkRepository!.lyric(id);
  if (lyric == null) {
    return null;
  }
  return LyricContent.from(lyric);
});
