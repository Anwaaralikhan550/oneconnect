import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/review_model.dart';
import '../widgets/partner_media_gallery.dart';
import '../widgets/profile_image.dart';
import '../utils/media_url.dart';

class ReviewMediaCenterScreen extends StatelessWidget {
  final String title;
  final List<ReviewModel> reviews;
  final List<PartnerGalleryItem> mediaItems;
  final int initialTabIndex;

  const ReviewMediaCenterScreen({
    super.key,
    required this.title,
    required this.reviews,
    required this.mediaItems,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final startIndex = initialTabIndex.clamp(0, 1);
    return DefaultTabController(
      length: 2,
      initialIndex: startIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reviews'),
              Tab(text: 'Photos & Videos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReviewsTab(reviews: reviews),
            _MediaTab(items: mediaItems),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<ReviewModel> reviews;

  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = reviews[index];
        final mediaUrl = resolveMediaUrl(r.mediaUrl);
        return Card(
          elevation: 0,
          color: const Color(0xFFF8F9FB),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: buildProfileImage(
                          r.userPhotoUrl,
                          iconSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(r.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${r.rating.toStringAsFixed(1)} ${r.ratingText ?? ''}'.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if ((r.reviewText ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(r.reviewText!.trim()),
                ],
                if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _ReviewMediaPreview(url: mediaUrl, mediaType: r.mediaType),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewMediaPreview extends StatelessWidget {
  final String url;
  final String? mediaType;

  const _ReviewMediaPreview({required this.url, this.mediaType});

  @override
  Widget build(BuildContext context) {
    final isVideo = (mediaType ?? '').toUpperCase() == 'VIDEO' || url.toLowerCase().endsWith('.mp4');
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE9EBEF),
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            if (isVideo)
              const Positioned.fill(
                child: Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaTab extends StatelessWidget {
  final List<PartnerGalleryItem> items;

  const _MediaTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No media yet'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final url = resolveMediaUrl(item.fileUrl);
        if (url == null || url.isEmpty) return const SizedBox.shrink();
        return InkWell(
          onTap: () async {
            final uri = Uri.tryParse(url);
            if (uri == null) return;
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE9EBEF),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              if (item.isVideo)
                const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
                ),
            ],
          ),
        );
      },
    );
  }
}
