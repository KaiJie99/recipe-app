import 'dart:io';

import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const _ImagePlaceholder(showProgress: true),
      );
    }
    final imageFile = File(imagePath);
    if (imagePath.isNotEmpty && imageFile.existsSync()) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Center(
      child: showProgress
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.restaurant_rounded,
              size: 34,
              color: Theme.of(context).colorScheme.primary,
            ),
    ),
  );
}
