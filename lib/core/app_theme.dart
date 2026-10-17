import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Light palette — warm white glass + PlayStation blue
// ---------------------------------------------------------------------------
const Color kBaseWhite = Color(0xFFFAF9F6);
const Color kFrontWhite = Color(0xFFFEFDFB);
const Color kPsBlue = Color(0xFF00439C);
const Color kPsBlueSoft = Color(0xFF3B6FC4);
const Color kPsBlueWash = Color(0xFFE7EEF8);
const Color kInk = Color(0xFF1C2333);
const Color kInkSoft = Color(0xFF5A6478);
const Color kHairline = Color(0xFFEDEAE4);
const Color kOutlinedBorderLight = Color(0xFFBBD0EC);

// ---------------------------------------------------------------------------
// Dark palette — "midnight indigo" glass (near-black indigo, no pure black)
// ---------------------------------------------------------------------------
const Color kDarkBase = Color(0xFF0F1220);
const Color kDarkBaseAlt = Color(0xFF161C2E);
const Color kDarkFront = Color(0xFF1A2236);
const Color kPsBlueBright = Color(0xFF5B8DEF);
const Color kDarkInk = Color(0xFFECF0FA);
const Color kDarkInkSoft = Color(0xFFA9B2C9);
const Color kDarkHairline = Color(0x26FFFFFF); // white @ 15%
const Color kOutlinedBorderDark = Color(0xFF31405F);
const Color kDarkOnPrimary = Color(0xFF0D1424); // dark text on bright buttons

/// Colors the glass widgets use, per brightness. Text inside glass always
/// comes from the [ThemeData] text roles, so contrast is guaranteed.
class GlassColors {
  /// Scales a glass color's alpha (used for extra-solid cards).
  static Color modulate(Color c, double factor) =>
      c.withValues(alpha: (c.a * factor).clamp(0.08, 1.0));

  static Color fill(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xA61A2236) // dark-indigo glass ~65%
      : Colors.white.withValues(alpha: 0.72);

  static Color fillAlt(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xCC202A44)
      : kFrontWhite.withValues(alpha: 0.74);

  static Color border(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0x2EFFFFFF) // white @ 18%
      : Colors.white.withValues(alpha: 0.75);

  /// Tiles nested inside a card: no blur, subtle fill.
  static Color tileFill(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.55);

  static Color shadow(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0x66000000)
      : const Color(0x141C2333);

  static Color accent(Brightness brightness) =>
      brightness == Brightness.dark ? kPsBlueBright : kPsBlue;

  /// Text color that sits on an accent (primary) surface — always contrasts.
  static Color onAccent(Brightness brightness) =>
      brightness == Brightness.dark ? kDarkOnPrimary : kFrontWhite;
}

ThemeData buildPlayTabTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final scheme = (dark
          ? ColorScheme.fromSeed(
              seedColor: kPsBlueBright,
              brightness: Brightness.dark,
              surface: kDarkBase,
            ).copyWith(
              surface: kDarkBase,
              surfaceContainerHighest: kDarkBaseAlt,
              primary: kPsBlueBright,
              onPrimary: kDarkOnPrimary,
              secondary: kPsBlueBright,
              onSurface: kDarkInk,
              onSurfaceVariant: kDarkInkSoft,
              outline: kDarkHairline,
              error: const Color(0xFFFF8A97),
            )
          : ColorScheme.fromSeed(
              seedColor: kPsBlue,
              surface: kBaseWhite,
            ).copyWith(
              surface: kBaseWhite,
              surfaceContainerHighest: kPsBlueWash,
              primary: kPsBlue,
              onPrimary: kFrontWhite,
              secondary: kPsBlueSoft,
              onSurface: kInk,
              onSurfaceVariant: kInkSoft,
              outline: kHairline,
            ))
      .copyWith(surface: dark ? kDarkBase : kBaseWhite);

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme.apply(
    bodyColor: dark ? kDarkInk : kInk,
    displayColor: dark ? kDarkInk : kInk,
  );

  final accent = GlassColors.accent(brightness);
  final onAccent = GlassColors.onAccent(brightness);
  final front = dark ? kDarkFront : kFrontWhite;
  final outlinedBorder = dark ? kOutlinedBorderDark : kOutlinedBorderLight;

  final systemIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: dark ? kDarkBase : kFrontWhite,
    systemNavigationBarIconBrightness:
        dark ? Brightness.light : Brightness.dark,
  );

  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: dark ? kDarkBase : kBaseWhite,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: dark ? kDarkInk : kInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: systemIcons,
      titleTextStyle: text.titleLarge!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: front,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: front,
      contentTextStyle: text.bodyMedium!.copyWith(
        color: dark ? kDarkInk : kInk,
      ),
      actionTextColor: accent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: dark ? kDarkHairline : kHairline),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onAccent,
      elevation: 3,
      highlightElevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: front,
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: outlinedBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: text.labelLarge
            ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: accent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: front,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dark ? kDarkHairline : kHairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dark ? kDarkHairline : kHairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: text.bodyMedium,
      hintStyle: text.bodyMedium!.copyWith(
        color: dark ? kDarkInkSoft : kInkSoft,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? accent : materialThumb(dark),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? (dark ? const Color(0xFF24365C) : kPsBlueWash)
            : (dark ? const Color(0xFF2A3350) : const Color(0xFFE5E1D8)),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => dark ? kDarkHairline : null,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
    dividerTheme: DividerThemeData(
      color: dark ? kDarkHairline : kHairline,
      thickness: 1,
    ),
    extensions: <ThemeExtension<dynamic>>[
      PlayTabExtension(dark: dark, front: front),
    ],
  );
}

Color materialThumb(bool dark) =>
    dark ? const Color(0xFF8892AB) : const Color(0xFFEFEDE7);

class PlayTabExtension extends ThemeExtension<PlayTabExtension> {
  const PlayTabExtension({required this.dark, required this.front});

  final bool dark;
  final Color front;

  @override
  PlayTabExtension copyWith({bool? dark, Color? front}) => PlayTabExtension(
        dark: dark ?? this.dark,
        front: front ?? this.front,
      );

  @override
  PlayTabExtension lerp(PlayTabExtension? other, double t) =>
      other == null ? this : (t < 0.5 ? this : other);
}
