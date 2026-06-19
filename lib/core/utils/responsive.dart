import 'package:flutter/material.dart';

/// Breakpoints aligned with common device sizes used for TubigTrack QA.
abstract final class ResponsiveBreakpoints {
  static const double smallPhone = 360;
  static const double mediumPhone = 411;
  static const double largePhone = 430;
  static const double tablet = 768;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.paddingOf(this);
  TextScaler get textScaler => MediaQuery.textScalerOf(this);

  bool get isSmallPhone => screenWidth < ResponsiveBreakpoints.mediumPhone;
  bool get isMediumPhone =>
      screenWidth >= ResponsiveBreakpoints.mediumPhone &&
      screenWidth < ResponsiveBreakpoints.largePhone;
  bool get isLargePhone =>
      screenWidth >= ResponsiveBreakpoints.largePhone &&
      screenWidth < ResponsiveBreakpoints.tablet;
  bool get isTablet => screenWidth >= ResponsiveBreakpoints.tablet;

  /// Columns for stat/summary card grids.
  int get statGridColumns => isTablet ? 4 : 2;

  /// Columns for action button grids (inventory, etc.).
  int get actionGridColumns => isTablet ? 4 : 2;

  /// Bottom padding for scrollable lists above a FAB.
  double get fabListBottomPadding =>
      kFloatingActionButtonMargin + kMinInteractiveDimension + viewPadding.bottom;

  /// Horizontal page padding that scales slightly on tablets.
  double get pageHorizontalPadding => isTablet ? 24 : 16;

  /// Max content width on tablets so content does not stretch edge-to-edge.
  double get contentMaxWidth => isTablet ? 720 : double.infinity;

  /// Scales a font size respecting accessibility text scaling with sane bounds.
  double scaledFontSize(double base) {
    final scaled = textScaler.scale(base);
    return scaled.clamp(base * 0.85, base * 1.35);
  }
}

/// Centers and constrains child width on tablets.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Responsive grid using [LayoutBuilder] + [Wrap].
class ResponsiveStatGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveStatGrid({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.statGridColumns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

/// Full-width primary action button with consistent height.
class ResponsivePrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final bool isLoading;

  const ResponsivePrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : child,
      ),
    );
  }
}
