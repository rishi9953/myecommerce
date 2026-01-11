import 'package:flutter/material.dart';

/// Responsive Service for handling different screen sizes
class ResponsiveService {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Get the current device type
  static DeviceType getDeviceType(BuildContext context) {
    return getDeviceTypeFromWidth(MediaQuery.of(context).size.width);
  }

  static DeviceType getDeviceTypeFromWidth(double width) {
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check device type
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop ||
      getDeviceType(context) == DeviceType.largeDesktop;

  /// Get responsive value based on device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context: context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 80.0,
        largeDesktop: 80.0,
      ),
      vertical: 20.0,
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: baseFontSize * 0.875,
      tablet: baseFontSize * 0.925,
      desktop: baseFontSize,
      largeDesktop: baseFontSize * 1.05,
    );
  }

  /// Get responsive width percentage
  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Get responsive height percentage
  static double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Get screen width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

/// Device Type Enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveService.getDeviceTypeFromWidth(
          constraints.maxWidth,
        );
        return builder(context, deviceType);
      },
    );
  }
}
