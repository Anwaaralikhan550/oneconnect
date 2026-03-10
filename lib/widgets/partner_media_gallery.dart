import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../utils/media_url.dart';

class PartnerGalleryItem {
  final String id;
  final String mediaType;
  final String fileUrl;

  const PartnerGalleryItem({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
  });

  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';
}

class PartnerMediaGallery extends StatelessWidget {
  final List<PartnerGalleryItem> items;
  final String title;
  final bool hideWhenEmpty;

  const PartnerMediaGallery({
    super.key,
    required this.items,
    this.title = 'Partner Media',
    this.hideWhenEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final cardW = sw * 0.42;
    final cardH = cardW * 0.72;

    if (items.isEmpty && hideWhenEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No media uploaded',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7E838B),
                ),
              ),
            )
          else
            SizedBox(
              height: cardH,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _GalleryCard(
                    item: item,
                    width: cardW,
                    height: cardH,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final PartnerGalleryItem item;
  final double width;
  final double height;

  const _GalleryCard({
    required this.item,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveMediaUrl(item.fileUrl) ?? item.fileUrl;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final uri = Uri.tryParse(resolvedUrl);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              item.isVideo
                  ? _VideoThumb(url: resolvedUrl)
                  : Image.network(
                      resolvedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    ),
              if (item.isVideo)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE9EBEF),
      child: const Icon(Icons.image_outlined, color: Color(0xFF8A9099)),
    );
  }
}

class _VideoThumb extends StatelessWidget {
  final String url;

  const _VideoThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        color: const Color(0xFFE9EBEF),
        child: const Icon(Icons.videocam_outlined, color: Color(0xFF8A9099)),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 380,
        quality: 60,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return Container(
            color: const Color(0xFFE9EBEF),
            child: const Icon(Icons.videocam_outlined, color: Color(0xFF8A9099)),
          );
        }
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
