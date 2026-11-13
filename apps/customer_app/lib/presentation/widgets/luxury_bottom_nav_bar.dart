import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../providers/cart_provider.dart';

class LuxuryBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  const LuxuryBottomNavBar({super.key, this.currentIndex = 0});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MarsNavigation(
        selectedIndex: currentIndex,
        onSelected: (index) {
          if (index == currentIndex) return;
          const paths = ['/home', '/search', '/cart', '/profile'];
          if (index == 0) {
            context.go(paths[index]);
          } else {
            context.push(paths[index]);
          }
        },
        destinations: [
          const MarsDestination('Discover', Icons.grid_view_rounded),
          const MarsDestination('Search', Icons.search_rounded),
          MarsDestination('Bag', Icons.shopping_bag_outlined,
              badge: ref.watch(cartSummaryProvider).itemCount),
          const MarsDestination('You', Icons.person_outline_rounded),
        ],
      );
}
