import 'package:quiet/repository.dart';
import 'package:riverpod/riverpod.dart';

final homePlaylistProvider = FutureProvider((ref) async {
  final list = await networkRepository!.personalizedPlaylist(limit: 6);
  return list.asFuture;
});

final personalizedNewSongProvider = FutureProvider((ref) async {
  final list = await networkRepository!.personalizedNewSong();
  return list.asFuture;
});
