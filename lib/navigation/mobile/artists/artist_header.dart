import 'package:flutter/material.dart';
import 'package:quiet/material.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

class ArtistHeader extends StatelessWidget {
  const ArtistHeader({Key? key, required this.artist}) : super(key: key);
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      flexibleSpace: _ArtistFlexHeader(artist: artist),
      elevation: 0,
      bottom: RoundedTabBar(
        tabs: <Widget>[
          Tab(text: context.strings.hotSong),
          Tab(text: context.strings.albumCount(artist.albumSize)),
          Tab(text: context.strings.videoCount(artist.mvSize)),
          Tab(text: context.strings.artistInfo),
        ],
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.share,
                color: Theme.of(context).primaryIconTheme.color),
            onPressed: null)
      ],
    );
  }
}

class _ArtistFlexHeader extends StatelessWidget {
  const _ArtistFlexHeader({Key? key, required this.artist}) : super(key: key);
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.bodyText2!,
      maxLines: 1,
      child: FlexibleDetailBar(
        background: FlexShadowBackground(
            child: QuietImage(
                url: (artist.picUrl), height: 300, fit: BoxFit.cover)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Text(
                    '${artist.name}${artist.alias.isEmpty ? '' : '(${artist.alias[0]})'}',
                    style: const TextStyle(fontSize: 20)),
                Text('${context.strings.cloudMusicUsage}:${artist.musicSize}'),
              ]),
        ),
        builder: (BuildContext context, double t) {
          return AppBar(
            title: Text(t > 0.5 ? artist.name : ''),
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: context.strings.share,
                  onPressed: () {
                    toast(context.strings.share);
                  })
            ],
          );
        },
      ),
    );
  }
}
