import 'package:flutter/material.dart';

/// A finite entrance, with no timers or animation work when motion is reduced.
class MarsReveal extends StatelessWidget {
  final Widget child;
  final int delay;
  const MarsReveal({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 620 + delay),
      curve: Interval(delay / (620 + delay), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)), child: child),
      ),
    );
  }
}

/// Keeps tab state alive while suspending tickers in hidden destinations.
class MarsTabStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  const MarsTabStack({super.key, required this.index, required this.children});

  @override
  Widget build(BuildContext context) => IndexedStack(
        index: index,
        children: List.generate(
            children.length,
            (i) => TickerMode(
                  enabled: i == index,
                  child:
                      ExcludeFocus(excluding: i != index, child: children[i]),
                )),
      );
}

class MarsPageTransitions extends PageTransitionsBuilder {
  const MarsPageTransitions();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final eased = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic);
    return FadeTransition(
        opacity: eased,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.025, 0.018), end: Offset.zero)
              .animate(eased),
          child: child,
        ));
  }
}
