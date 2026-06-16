import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/network/api_constants.dart';

/// Renders a product or service image from any of three formats the backend
/// may send: absolute URL, relative path, or base64 data URI.
class ItemImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color fallbackBg;
  final Color fallbackColor;

  const ItemImage({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.borderRadius,
    required this.fallbackIcon,
    required this.fallbackBg,
    required this.fallbackColor,
  });

  /// Decodes a `data:<mime>;base64,<data>` URI into raw bytes.
  /// Returns null if the value is not a data URI or decoding fails.
  Uint8List? _decodeBase64() {
    final raw = imageUrl?.trim();
    if (raw == null || !raw.startsWith('data:')) return null;
    try {
      final comma = raw.indexOf(',');
      if (comma == -1) return null;
      return base64.decode(raw.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  /// Resolves the stored value to a fully-qualified HTTPS URL.
  /// Returns null for base64 data URIs (handled by [_decodeBase64]).
  String? _resolveUrl() {
    var raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('data:')) return null; // handled as base64
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (!kIsWeb && Platform.isAndroid) {
        if (raw.contains('//localhost:8000')) {
          raw = raw.replaceAll('//localhost:8000', '//10.0.2.2:8000');
        } else if (raw.contains('//127.0.0.1:8000')) {
          raw = raw.replaceAll('//127.0.0.1:8000', '//10.0.2.2:8000');
        } else if (raw.contains('//localhost:')) {
          raw = raw.replaceAll('//localhost:', '//10.0.2.2:');
        } else if (raw.contains('//127.0.0.1:')) {
          raw = raw.replaceAll('//127.0.0.1:', '//10.0.2.2:');
        }
      }
      return raw;
    }
    // Relative path — prepend API base URL
    return '${ApiConstants.baseUrl}${raw.startsWith('/') ? raw : '/$raw'}';
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeBase64();
    final url = _resolveUrl();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: bytes != null
            ? Image.memory(
                bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : url != null
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    frameBuilder: (_, child, frame, sync) =>
                        sync || frame != null ? child : _fallback(),
                    errorBuilder: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
        color: fallbackBg,
        child: Icon(fallbackIcon, color: fallbackColor, size: size * 0.45),
      );
}
