import '../config/api_config.dart';

String apiOrigin() {
  final base = Uri.tryParse(ApiConfig.baseUrl);
  if (base == null || base.host.isEmpty) return '';
  final port = base.hasPort ? ':${base.port}' : '';
  return '${base.scheme}://${base.host}$port';
}

String? resolveMediaUrl(String? rawUrl) {
  final raw = (rawUrl ?? '').trim();
  if (raw.isEmpty) return null;

  final origin = apiOrigin();

  if (raw.startsWith('/uploads/')) {
    return origin.isEmpty ? raw : '$origin$raw';
  }
  if (raw.startsWith('uploads/')) {
    return origin.isEmpty ? '/$raw' : '$origin/$raw';
  }

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasScheme) return raw;

  if ((uri.host == 'localhost' || uri.host == '127.0.0.1') && origin.isNotEmpty) {
    final fallback = Uri.parse(origin);
    return uri.replace(
      scheme: fallback.scheme,
      host: fallback.host,
      port: fallback.hasPort ? fallback.port : null,
    ).toString();
  }

  return raw;
}
