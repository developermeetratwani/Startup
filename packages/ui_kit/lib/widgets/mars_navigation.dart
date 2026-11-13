import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MarsDestination {
  final String label;
  final IconData icon;
  final int badge;
  const MarsDestination(this.label, this.icon, {this.badge = 0});
}

class MarsNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<MarsDestination> destinations;
  final Color accent;
  const MarsNavigation(
      {super.key,
      required this.selectedIndex,
      required this.onSelected,
      required this.destinations,
      this.accent = AppColors.accent});

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: AppColors.onyx,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 24,
                    offset: Offset(0, 8))
              ]),
          child: Row(
              children: List.generate(destinations.length, (i) {
            final selected = selectedIndex == i;
            final destination = destinations[i];
            return Expanded(
                child: Semantics(
              selected: selected,
              button: true,
              label:
                  '${destination.label}${destination.badge > 0 ? ', ${destination.badge} pending' : ''}',
              child: Tooltip(
                  message: destination.label,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelected(i),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: Duration(
                            milliseconds:
                                MediaQuery.disableAnimationsOf(context)
                                    ? 0
                                    : 260),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: selected ? accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Badge(
                              isLabelVisible: destination.badge > 0,
                              label: Text('${destination.badge}'),
                              child: Icon(destination.icon,
                                  size: 21,
                                  color: selected
                                      ? AppColors.textOnDark
                                      : AppColors.textHint)),
                          const SizedBox(height: 5),
                          Text(destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 10,
                                  color: selected
                                      ? AppColors.textOnDark
                                      : AppColors.textHint)),
                        ]),
                      ),
                    ),
                  )),
            ));
          })),
        ),
      );
}
