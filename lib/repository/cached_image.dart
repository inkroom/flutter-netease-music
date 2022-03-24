import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/component/cache/key_value_cache.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository/database.dart';

///default image size in dimens
const _defaultImageSize = Size.fromWidth(200);

///image provider for network image
class CachedImage extends ImageProvider<CachedImage> implements CacheKey {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  CachedImage(this.url, {this.scale = 1.0, this.headers}) : _size = null;

  static CachedImage? _notImage;

  static CachedImage? _imageFail;

  factory CachedImage.notImage() {
    return _notImage ??= CachedImage('网络禁止');
  }

  factory CachedImage.imageFail() {
    return _imageFail ??= CachedImage('图片失败');
  }

  const CachedImage._internal(this.url, this._size,
      {this.scale = 1.0, this.headers});

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// the size in pixel (widget & height) of this image
  /// might be null
  final Size? _size;

  int get height => _size == null || _size!.height == double.infinity
      ? -1
      : _size!.height.toInt();

  int get width => _size == null || _size!.width == double.infinity
      ? -1
      : _size!.width.toInt();

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String>? headers;

  ///the id of this image
  ///netease image url has a unique id at url last part
  String get id => url.isEmpty
      ? ''
      : url.substring(url.lastIndexOf('/') == -1 ? 0 : url.lastIndexOf('/'));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          scale == other.scale &&
          _size == other._size;

  @override
  int get hashCode => hashValues(id, scale, _size);

  @override
  ImageStreamCompleter load(CachedImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode), scale: key.scale);
  }

  static final HttpClient _httpClient = HttpClient();

  /// 加载占位图
  Future<ui.Codec> _loadNotImageAsync(DecoderCallback decode) async {
    var data = await rootBundle.load("assets/not_image.png");
    return decode(data.buffer.asUint8List(),
        cacheWidth: null, cacheHeight: null);
  }

  Future<ui.Codec> _loadAsync(CachedImage key, DecoderCallback decode) async {
    final cache = await _imageCache();
    final image = await cache.get(key);
    if (image != null) {
      log("图片缓存 ${key.url}  命中本地文件缓存");
      return decode(Uint8List.fromList(image),
          cacheWidth: key.width, cacheHeight: null);
    }

    if (key.url.isEmpty) {
      throw const QuietException('image url is empty.');
    }
    log("图片缓存 ${key.url}  从网络加载图片");
    //request network source
    final Uri resolved = Uri.base.resolve(key.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw QuietException(
          'HTTP request failed, statusCode: ${response.statusCode}, $resolved');
    }

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) {
      throw QuietException('NetworkImage is an empty file: $resolved');
    }

    //save image to cache
    await cache.update(key, bytes);

    return decode(Uint8List.fromList(bytes),
        cacheWidth: key.width, cacheHeight: null);
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream,
      CachedImage key, ImageErrorListener handleError) async {
    // super.resolveStreamForKey(configuration, stream, key, handleError);

    if (stream.completer != null) {
      final ImageStreamCompleter? completer =
          PaintingBinding.instance!.imageCache!.putIfAbsent(
        key,
        () => stream.completer!,
        onError: handleError,
      );
      assert(identical(completer, stream.completer));
      return;
    }

    /// 先使用图片本身的key去查找缓存（包括本类实现的文件缓存），如果缓存存在，就返回缓存，
    ///
    /// 如果缓存不存在，但是网络正常，直接获取图片
    ///
    /// 如果缓存不存在，且此时网络关闭，那么就去获取一份指向占位图的缓存
    ///

    ///
    /// 如果占位图缓存不存在，就加载占位图
    ///
    final cache = await _imageCache();
    final image = await cache.get(key);
    ImageStreamCompleter? completer;
    final s = PaintingBinding.instance!.imageCache!.statusForKey(key);
    if (s.keepAlive ||
        s.live ||
        image != null ||
        NetworkSingleton.instance.allowNetwork()) {
      log("图片缓存 ${key.url} 允许加载");

      /// 获取缓存
      completer = PaintingBinding.instance!.imageCache!.putIfAbsent(
        key,
        () => load(key, PaintingBinding.instance!.instantiateImageCodec),
        onError: null, //必须为null，不然catch没有用
      );
    } else {
      /// 缓存不存在，且网络关闭
      key = CachedImage.notImage();
      log("图片缓存 ${key.url} 缓存不存在，且网络关闭");

      /// 尝试获取占位图的缓存
      completer = PaintingBinding.instance!.imageCache!.putIfAbsent(
        key,
        () {
          log("图片缓存 ${key.url} 占位图缓存不存在，加载占位图");

          /// 占位图没有缓存，从文件中加载
          ///
          return MultiFrameImageStreamCompleter(
              codec: _loadNotImageAsync(
                  PaintingBinding.instance!.instantiateImageCodec),
              scale: key.scale);
        },
        onError: handleError,
      );
    }
    if (completer != null) {
      stream.setCompleter(completer);
    }
  }

  @override
  Future<CachedImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImage>(CachedImage._internal(
        url,
        (configuration.size ?? _defaultImageSize) *
            configuration.devicePixelRatio!,
        scale: scale,
        headers: headers));
  }

  @override
  String toString() {
    return 'CacheImage{url: $url, scale: $scale, size: $_size}';
  }

  @override
  String getKey() {
    return id;
  }
}

_ImageCache? __imageCache;

Future<_ImageCache> _imageCache() async {
  if (__imageCache != null) {
    return __imageCache!;
  }
  var dir = Directory(await getThumbDirectory());
  if (!(await dir.exists())) {
    dir = await dir.create();
  }
  __imageCache = _ImageCache(dir);
  return __imageCache!;
}

///cache netease image data
class _ImageCache implements Cache<Uint8List?> {
  _ImageCache(Directory dir)
      : provider =
            FileCacheProvider(dir.path, maxSize: 600 * 1024 * 1024 /* 600 Mb*/);

  final FileCacheProvider provider;

  @override
  Future<Uint8List?> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      provider.touchFile(file);
      return Uint8List.fromList(await file.readAsBytes());
    }
    return null;
  }

  @override
  Future<bool> update(CacheKey key, Uint8List? t) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
      file.delete();
    }
    file = await file.create();
    await file.writeAsBytes(t!);
    try {
      return await file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
