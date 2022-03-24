import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiet/repository.dart';

///圆形图片
class RoundedImage extends StatelessWidget {
  const RoundedImage(this.url, {Key? key, this.size = 48}) : super(key: key);

  ///图片直径
  final double size;

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: SizedBox.fromSize(
      size: Size.square(size),
      child: QuietImage(
        url: url,
        height: size,
        width: size,
      ),
    ));
  }
}

/// 自定义图片加载 ， 主要是固定了 一些 hook 方法
class QuietImage extends StatelessWidget {
  QuietImage({
    Key? key,
    this.url,
    this.assets,
    this.loadingBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  }) : super(key: key) {
    // assert(url == null && assets == null);
  }

  final String? url;

  /// 和url同时存在时，url优先级更高
  final String? assets;

  // 下面的参数都是直接从 Image 类里复制来的

  final ImageLoadingBuilder? loadingBuilder;

  final double? width;

  final double? height;

  final Color? color;

  final Animation<double>? opacity;

  final FilterQuality filterQuality;

  final BlendMode? colorBlendMode;

  final BoxFit? fit;

  final AlignmentGeometry alignment;

  final ImageRepeat repeat;

  final Rect? centerSlice;

  final bool matchTextDirection;

  final bool gaplessPlayback;

  final String? semanticLabel;

  final bool excludeFromSemantics;

  final bool isAntiAlias;

  @override
  Widget build(BuildContext context) {
    ImageProvider i;

    if (url != null && url!.isNotEmpty) {
      i = CachedImage(url!);
    } else if (assets != null) {
      i = AssetImage(assets!);
    } else {
      /// 都是空，加载默认图片
      i = const AssetImage('assets/image_fail.png');
    }

    return Image(
        width: width,
        height: height,
        color: color,
        opacity: opacity,
        filterQuality: filterQuality,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        isAntiAlias: isAntiAlias,
        image: i,
        loadingBuilder: loadingBuilder ??
            (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              return loadingProgress == null
                  ? child
                  : const CircularProgressIndicator();
            },
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          log('errorBuilder = $error');
          return Image(
            image: const AssetImage('assets/image_fail.png'),
            width: width,
            height: height,
            color: color,
            opacity: opacity,
            filterQuality: filterQuality,
            colorBlendMode: colorBlendMode,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            centerSlice: centerSlice,
            matchTextDirection: matchTextDirection,
            gaplessPlayback: gaplessPlayback,
            semanticLabel: semanticLabel,
            excludeFromSemantics: excludeFromSemantics,
            isAntiAlias: isAntiAlias,
          );
        });
  }
}

/// 原先头像
///
class QuietCircleAvatar extends StatelessWidget {
  const QuietCircleAvatar({
    Key? key,
    this.child,
    this.backgroundColor,
    this.backgroundImage,
    this.foregroundImage,
    this.foregroundColor,
    this.radius,
    this.minRadius,
    this.maxRadius,
  })  : assert(radius == null || (minRadius == null && maxRadius == null)),
        assert(backgroundImage != null),
        assert(foregroundImage != null),
        super(key: key);

  // 以下复制自 CircleAvatar

  final Widget? child;

  final Color? backgroundColor;

  final Color? foregroundColor;

  final ImageProvider? backgroundImage;

  final ImageProvider? foregroundImage;

  final double? radius;

  final double? minRadius;

  final double? maxRadius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: child,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      backgroundImage: backgroundImage,
      foregroundImage: foregroundImage,
      radius: radius,
      minRadius: minRadius,
      maxRadius: maxRadius,
      onBackgroundImageError: (Object exception, StackTrace? stackTrace) =>
          log('头像背景图片加载失败 = $exception $stackTrace'),
      onForegroundImageError: (Object exception, StackTrace? stackTrace) =>
          log('头像前景图片加载失败 = $exception $stackTrace'),
    );
  }
}
