/// Spacing scale used for padding, gaps and margins across the app.
///
/// Keeping every screen on this scale is what gives the layout its
/// "generous, calm" rhythm described in the design brief — avoid one-off
/// magic numbers in new screens.
library;

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Vertical rhythm between major sections on a screen.
  static const double section = 40;
}
