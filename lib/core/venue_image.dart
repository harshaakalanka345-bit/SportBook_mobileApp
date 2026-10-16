import 'package:flutter/material.dart';

import 'sports.dart';

/// Displays a venue's uploaded photo when available and a bundled sport photo
/// otherwise. The local image remains visible while a remote photo loads or if
/// the network image cannot be decoded.
class VenueImage extends StatelessWidget {
  const VenueImage({
    super.key,
    required this.venue,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final Map<String, dynamic> venue;
  final BoxFit fit;
  final Alignment alignment;

  String? get _localAsset {
    final sport = '${venue['sport'] ?? ''}'.toLowerCase();
    if (sport.contains('cricket') || sport.contains('basketball')) return null;
    if (sport.contains('futsal') || sport.contains('football')) {
      return 'assets/venues/indoor_futsal.png';
    }
    if (sport.contains('tennis')) {
      return 'assets/venues/outdoor_tennis.png';
    }
    if (sport.isEmpty || sport.contains('badminton')) {
      return 'assets/venues/indoor_badminton.png';
    }
    return null;
  }

  Widget _fallback() {
    final asset = _localAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _sportPlaceholder(),
      );
    }
    return _sportPlaceholder();
  }

  Widget _sportPlaceholder() => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFDCE8FF), Color(0xFFBFD2FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        sportIcon('${venue['sport'] ?? ''}'),
        size: 48,
        color: Colors.blue.shade700,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${venue['image_url'] ?? ''}'.trim();
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return _fallback();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _fallback(),
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }
}
