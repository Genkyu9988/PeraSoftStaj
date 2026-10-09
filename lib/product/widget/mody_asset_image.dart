import 'dart:io';
import 'package:flutter/material.dart';
import 'package:perasoft_staj/product/init/theme/color_items.dart';

// VB10's PngImage approach, with fit and dimensions supplied by the caller.
class ModyAssetImage extends StatelessWidget {
  const ModyAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image(
    image: path.startsWith('mody-media:')
        ? _generatedImage(path)
        : path.startsWith('https://')
        ? NetworkImage(path)
        : path.startsWith('assets/')
        ? AssetImage(path)
        : FileImage(
                File(
                  path.startsWith('file:')
                      ? Uri.parse(path).toFilePath()
                      : path,
                ),
              )
              as ImageProvider,
    fit: fit,
    width: width,
    height: height,
    semanticLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
    errorBuilder: (context, error, stackTrace) => SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          semanticLabel: 'Görsel yüklenemedi',
          color: ColorItems.secondaryText,
        ),
      ),
    ),
  );

  ImageProvider _generatedImage(String path) {
    final base = Uri.parse(
      const String.fromEnvironment(
        'MODY_API_URL',
        defaultValue: 'http://10.0.2.2:8765',
      ),
    );
    if (base.userInfo.isNotEmpty ||
        !(base.scheme == 'https' ||
            (base.scheme == 'http' &&
                [
                  '10.0.2.2',
                  '127.0.0.1',
                  'localhost',
                  '::1',
                ].contains(base.host)))) {
      throw StateError('Unsafe backend media address');
    }
    final id = path.substring('mody-media:'.length);
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(id)) {
      throw StateError('Invalid media ID');
    }
    return NetworkImage(
      base
          .resolve('/api/v1/ai/media')
          .replace(queryParameters: {'id': id})
          .toString(),
      headers: const {
        'Authorization': 'Bearer ${String.fromEnvironment('MODY_API_TOKEN')}',
      },
    );
  }
}
