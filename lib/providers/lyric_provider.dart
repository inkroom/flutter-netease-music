import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final lyricProvider =
    FutureProvider.family<LyricContent?, Track>((ref, id) async {
  final lyric = await networkRepository!.lyric(id);
  if (lyric == null) {
    return null;
  }
  return lyric;
});
