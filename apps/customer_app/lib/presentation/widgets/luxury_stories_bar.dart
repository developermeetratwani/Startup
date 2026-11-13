import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class StoryItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;
  final bool isLive;
  final List<Color> gradientColors;

  const StoryItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.tag,
    this.isLive = false,
    this.gradientColors = const [Color(0xFFD93670), Color(0xFFF04438), Color(0xFFA78BFA)],
  });
}

class LuxuryStoriesBar extends StatelessWidget {
  final Function(String tag)? onStorySelected;

  const LuxuryStoriesBar({super.key, this.onStorySelected});

  static const List<StoryItem> stories = [
    StoryItem(
      title: 'Flash Drops',
      subtitle: 'Flat 50% Off',
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&auto=format&fit=crop',
      tag: 'flash',
      isLive: true,
      gradientColors: [Color(0xFFE11D48), Color(0xFFF97316), Color(0xFFFBBF24)],
    ),
    StoryItem(
      title: 'SwiftDrop Gold',
      subtitle: 'VIP Perks',
      imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=400&auto=format&fit=crop',
      tag: 'gold',
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF78350F)],
    ),
    StoryItem(
      title: 'Ethnic Luxe',
      subtitle: 'Handcrafted',
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&auto=format&fit=crop',
      tag: 'ethnic',
      gradientColors: [Color(0xFFD93670), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    StoryItem(
      title: 'Streetwear',
      subtitle: 'Oversized',
      imageUrl: 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=400&auto=format&fit=crop',
      tag: 'western',
      gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFF10B981)],
    ),
    StoryItem(
      title: 'Under 20m',
      subtitle: '⚡ Express',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&auto=format&fit=crop',
      tag: 'fast',
      isLive: true,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    ),
    StoryItem(
      title: 'Boutiques',
      subtitle: 'Verified',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&auto=format&fit=crop',
      tag: 'all',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final s = stories[index];

          return GestureDetector(
            onTap: () {
              if (onStorySelected != null) {
                onStorySelected!(s.tag);
              }
              _showStoryModal(context, s);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient Ring
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: s.gradientColors),
                        boxShadow: [
                          BoxShadow(
                            color: s.gradientColors.first.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    // White Gap
                    Container(
                      width: 61,
                      height: 61,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Avatar Image
                    ClipOval(
                      child: ProductImage(
                        imageUrl: s.imageUrl,
                        width: 57,
                        height: 57,
                      ),
                    ),
                    if (s.isLive)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStoryModal(BuildContext context, StoryItem story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Color(0xFF0F1016),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Stack(
          children: [
            // Background Image with dark overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: ProductImage(
                  imageUrl: story.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99000000),
                      Colors.transparent,
                      Color(0xF00F1016),
                    ],
                  ),
                ),
              ),
            ),
            // Header Content
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(story.imageUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          story.subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // Bottom CTA
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    'Exclusive Curated Drop • Ahmedabad Hub',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delivered to your doorstep in 15-20 minutes with 48-Hour Free Size Exchange Guarantee.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('EXPLORE COLLECTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
