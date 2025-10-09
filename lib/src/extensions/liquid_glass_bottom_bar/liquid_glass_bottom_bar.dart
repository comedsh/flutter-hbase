import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badge;
  const LiquidGlassBottomBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
  });
}

class LiquidGlassBottomBar extends StatelessWidget {
  /// 这是源库中的 padding size，这个值还不能随便改，如果将 left padding 或者 right padding 去掉了，
  /// bottom liquid glass appbar 的动态切换效果就会出现毛边了
  static const paddingBottomSize = 12.0;
  static const barHeightWithLabels = 74.0;
  static const barHeightWithoutLabels = 56.0;

  final List<LiquidGlassBottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Auto height: 74 (with labels) / 56 (without labels)
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool showLabels;

  /// Accent color for the active item (icon/label).
  final Color activeColor;

  /// Blur intensity for the bar and for the active pill.
  final double barBlurSigma;
  final double activeBlurSigma;

  const LiquidGlassBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height,
    this.margin,
    this.showLabels = true,
    this.activeColor = const Color(0xFF34C3FF),
    this.barBlurSigma = 20,
    this.activeBlurSigma = 28,
  }) : assert(items.length >= 2, 'At least 2 items are required.');

  @override
  Widget build(BuildContext context) {
    // final media = MediaQuery.of(context);
    final double barH = height ?? (showLabels ? barHeightWithLabels : barHeightWithoutLabels);
    // final double bottomSafe = media.padding.bottom * 0.35;
    // final double bottomSafe = 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: margin ?? EdgeInsets.fromLTRB(14, 0, 14, paddingBottomSize),
        child: SizedBox(
          height: barH,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Bar frosted background (global blur, no borders)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: barBlurSigma,
                        sigmaY: barBlurSigma,
                      ),
                      child: Container(color: Colors.white.withAlpha(10)),
                    ),
                  ),
                ),
                // Soft drop shadow (no outline)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 14,
                            /// 去掉的原因是，实际测试过程中，首页切换过程中会产生虚幻的毛边... 
                            // offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        
                // Sliding pill (single instance)
                _SlidingActivePill(
                  items: items,
                  currentIndex: currentIndex,
                  barHeight: barH,
                  blurSigma: activeBlurSigma,
                  showLabels: showLabels,
                ),
        
                // Items on top
                Row(
                  children: List.generate(items.length, (i) {
                    final it = items[i];
                    final selected = i == currentIndex;
                    final iconColor =
                        selected ? activeColor : Colors.white.withAlpha(185);
                    final textColor =
                        selected ? activeColor : Colors.white.withAlpha(210);
        
                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(i),
                        customBorder: const StadiumBorder(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: showLabels ? 10 : 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    selected
                                        ? (it.activeIcon ?? it.icon)
                                        : it.icon,
                                    size: 22,
                                    color: iconColor,
                                  ),
                                  if ((it.badge ?? 0) > 0)
                                    Positioned(
                                      right: -8,
                                      top: -6,
                                      child: _Badge(count: it.badge!),
                                    ),
                                ],
                              ),
                              if (showLabels) ...[
                                const SizedBox(height: 4),
                                Text(
                                  it.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: textColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// SINGLE pill sliding between items.
/// Uses AnimatedPositioned with width computed from the active tab’s content.
class _SlidingActivePill extends StatelessWidget {
  final List<LiquidGlassBottomBarItem> items;
  final int currentIndex;
  final double barHeight;
  final double blurSigma;
  final bool showLabels;

  const _SlidingActivePill({
    required this.items,
    required this.currentIndex,
    required this.barHeight,
    required this.blurSigma,
    required this.showLabels,
  });

  double _textWidth(String text, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final slots = items.length;
      final slotW = c.maxWidth / slots;
      final vPad = showLabels ? 8.0 : 6.0;
      final pillH = barHeight - vPad * 2;

      // Pill width based on the active tab content
      final contentW = showLabels
          ? 24 + 6 + _textWidth(items[currentIndex].label, slotW)
          : 24;
      final padH = showLabels ? 20.0 : 14.0;
      final pillW = (contentW + padH * 2).clamp(48.0, slotW - 12.0);

      // Left offset to center the pill within the current slot
      final left = slotW * currentIndex + (slotW - pillW) / 2;

      return Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: left,
            top: vPad,
            width: pillW,
            height: pillH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Strong blur (glass)
                    BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: blurSigma, sigmaY: blurSigma),
                      child: const SizedBox.expand(),
                    ),
                    // Minimal veil (almost pure blur)
                    Container(color: Colors.white.withAlpha(6)),
                    // Top highlight (no halo, no border)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withAlpha(42),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withAlpha(235),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(200), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1),
      ),
    );
  }
}