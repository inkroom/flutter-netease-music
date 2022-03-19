import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final cloudTracksProvider =
    StateNotifierProvider<CloudTrackDetailNotifier, CloudTracksDetailState>(
  (ref) => CloudTrackDetailNotifier(),
);
