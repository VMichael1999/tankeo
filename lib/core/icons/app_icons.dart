import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Íconos de trazo (24 × 24) idénticos a los símbolos SVG del prototipo.
enum AppIcon {
  alert(
    r'<path d="M12 9v4M10.363 3.591l-8.106 13.534a1.914 1.914 0 0 0 1.636 2.871h16.214a1.914 1.914 0 0 0 1.636-2.87l-8.106-13.536a1.914 1.914 0 0 0-3.274 0zM12 16h.01"/>',
  ),
  close(r'<path d="M18 6l-12 12M6 6l12 12"/>'),
  gift(
    r'<rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7M7.5 8a2.5 2.5 0 0 1 0-5A4.8 8 0 0 1 12 8a4.8 8 0 0 1 4.5-5a2.5 2.5 0 0 1 0 5"/>',
  ),
  card(
    r'<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M3 10h18M7 15h2"/>',
  ),
  phone(
    r'<path d="M5 4h4l2 5l-2.5 1.5a11 11 0 0 0 5 5l1.5-2.5l5 2v4a2 2 0 0 1-2 2a16 16 0 0 1-15-15a2 2 0 0 1 2-2"/>',
  ),
  receipt(
    r'<path d="M5 21v-16a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16l-3-2l-2 2l-2-2l-2 2l-2-2l-3 2M9 7h6M9 11h6M9 15h4"/>',
  ),
  help(
    r'<circle cx="12" cy="12" r="9"/><path d="M12 17v.01M12 13.5a1.5 1.5 0 0 1 1-1.5a2.6 2.6 0 1 0-3-4"/>',
  ),
  flag(r'<path d="M5 21v-16M5 5h13l-3 4.5l3 4.5h-13"/>'),
  navArrow(r'<path d="M12 3l7 18l-7-4l-7 4z"/>'),
  turnRight(r'<path d="M7 20v-9a4 4 0 0 1 4-4h8M15 3l4 4l-4 4"/>'),
  turnLeft(r'<path d="M17 20v-9a4 4 0 0 0-4-4h-8M9 3l-4 4l4 4"/>'),
  straight(r'<path d="M12 20v-16M7 9l5-5l5 5"/>'),
  trash(
    r'<path d="M4 7h16M10 11v6M14 11v6M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2l1-12M9 7v-3h6v3"/>',
  ),
  tag(
    r'<path d="M7.5 7.5h.01M3 6v5.172a2 2 0 0 0 .586 1.414l7.71 7.71a2.41 2.41 0 0 0 3.408 0l5.592-5.592a2.41 2.41 0 0 0 0-3.408l-7.71-7.71a2 2 0 0 0-1.414-.586h-5.172a3 3 0 0 0-3 3"/>',
  ),
  car(
    r'<path d="M5 17h-1a1 1 0 0 1-1-1v-4l2-5h14l2 5v4a1 1 0 0 1-1 1h-1M8 17h8M3 12h18"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/>',
  ),
  map(r'<path d="M3 7l6-3l6 3l6-3v13l-6 3l-6-3l-6 3v-13M9 4v13M15 7v13"/>'),
  hex(
    r'<path d="M12 3l8 4.5v9l-8 4.5l-8-4.5v-9z"/><circle cx="12" cy="12" r="3"/>',
  ),
  bell(
    r'<path d="M10 5a2 2 0 1 1 4 0a7 7 0 0 1 4 6v3a4 4 0 0 0 2 3h-16a4 4 0 0 0 2-3v-3a7 7 0 0 1 4-6M9 17v1a3 3 0 0 0 6 0v-1"/>',
  ),
  chev(r'<path d="M9 6l6 6l-6 6"/>'),
  down(r'<path d="M6 9l6 6l6-6"/>'),
  back(r'<path d="M19 12h-14M11 18l-6-6M11 6l-6 6"/>'),
  pin(
    r'<circle cx="12" cy="11" r="3"/><path d="M17.657 16.657l-4.243 4.243a2 2 0 0 1-2.827 0l-4.244-4.243a8 8 0 1 1 11.314 0z"/>',
  ),
  dots(
    r'<circle cx="5" cy="12" r="1.3"/><circle cx="12" cy="12" r="1.3"/><circle cx="19" cy="12" r="1.3"/>',
  ),
  route(
    r'<circle cx="6" cy="19" r="2"/><circle cx="18" cy="5" r="2"/><path d="M12 19h4.5a3.5 3.5 0 0 0 0-7h-8a3.5 3.5 0 0 1 0-7h3.5"/>',
  ),
  lock(
    r'<rect x="5" y="11" width="14" height="10" rx="2"/><circle cx="12" cy="16" r="1"/><path d="M8 11v-4a4 4 0 1 1 8 0v4"/>',
  ),
  lamp(
    r'<path d="M9 18h6M10 21h4M12 15v3M6 8a6 6 0 0 1 12 0c0 3-2 4-3 7h-6c-1-3-3-4-3-7z"/>',
  ),
  coin(
    r'<circle cx="12" cy="12" r="9"/><path d="M14.8 9a2 2 0 0 0-1.8-1h-2a2 2 0 1 0 0 4h2a2 2 0 1 1 0 4h-2a2 2 0 0 1-1.8-1M12 6v2M12 16v2"/>',
  ),
  check(r'<path d="M5 12l5 5l10-10"/>'),
  mail(
    r'<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M3 8l9 6l9-6"/>',
  ),
  eyeOff(
    r'<path d="M10.585 10.587a2 2 0 0 0 2.829 2.828M16.681 16.673a8.717 8.717 0 0 1-4.681 1.327c-3.6 0-6.6-2-9-6c1.272-2.12 2.712-3.678 4.32-4.674m2.86-1.146a9.055 9.055 0 0 1 1.82-.18c3.6 0 6.6 2 9 6c-.666 1.11-1.379 2.067-2.138 2.87M3 3l18 18"/>',
  ),
  eye(
    r'<path d="M10 12a2 2 0 1 0 4 0a2 2 0 0 0-4 0"/><path d="M21 12c-2.4 4-5.4 6-9 6c-3.6 0-6.6-2-9-6c2.4-4 5.4-6 9-6c3.6 0 6.6 2 9 6"/>',
  ),
  wallet(
    r'<path d="M17 8v-3a1 1 0 0 0-1-1h-10a2 2 0 0 0 0 4h12a1 1 0 0 1 1 1v3m0 4v3a1 1 0 0 1-1 1h-12a2 2 0 0 1-2-2v-12"/><path d="M20 12v4h-4a2 2 0 0 1 0-4h4"/>',
  ),
  heart(
    r'<path d="M19.5 12.572l-7.5 7.428l-7.5-7.428a5 5 0 1 1 7.5-6.566a5 5 0 1 1 7.5 6.572"/>',
  ),
  filter(
    r'<path d="M4 6h8M16 6h4M4 12h2M10 12h10M4 18h11M19 18h1"/><circle cx="14" cy="6" r="2"/><circle cx="8" cy="12" r="2"/><circle cx="17" cy="18" r="2"/>',
  ),
  plus(r'<path d="M12 5v14M5 12h14"/>'),
  minus(r'<path d="M5 12h14"/>'),
  target(
    r'<circle cx="12" cy="12" r="3"/><circle cx="12" cy="12" r="7"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/>',
  ),
  send(
    r'<path d="M10 14l11-11M21 3l-6.5 18a.55.55 0 0 1-1 0l-3.5-7l-7-3.5a.55.55 0 0 1 0-1l18-6.5"/>',
  ),
  store(
    r'<path d="M3 21h18M3 7v1a3 3 0 0 0 6 0v-1m0 1a3 3 0 0 0 6 0v-1m0 1a3 3 0 0 0 6 0v-1h-18l2-4h14l2 4M5 21v-10.85M19 21v-10.85M9 21v-4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v4"/>',
  ),
  users(
    r'<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2M16 3.13a4 4 0 0 1 0 7.75M21 21v-2a4 4 0 0 0-3-3.85"/>',
  ),
  shield(
    r'<path d="M12 3a12 12 0 0 0 8.5 3a12 12 0 0 1-8.5 15a12 12 0 0 1-8.5-15a12 12 0 0 0 8.5-3"/><path d="M9 12l2 2l4-4"/>',
  ),
  clock(r'<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/>'),
  photo(
    r'<path d="M15 8h.01"/><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M3 16l5-5c.928-.893 2.072-.893 3 0l5 5M14 14l1-1c.928-.893 2.072-.893 3 0l3 3"/>',
  ),
  starFilled(
    r'<path d="M8.243 7.34l-6.38 .925l-.113 .023a1 1 0 0 0-.44 1.684l4.622 4.499l-1.09 6.355l-.013 .11a1 1 0 0 0 1.464 .944l5.706-3l5.693 3l.1 .046a1 1 0 0 0 1.352-1.1l-1.091-6.355l4.624-4.5l.078-.085a1 1 0 0 0-.633-1.62l-6.38-.926l-2.852-5.78a1 1 0 0 0-1.794 0l-2.853 5.78z"/>',
  ),
  pump(
    r'<path d="M14 11h1a2 2 0 0 1 2 2v3a1.5 1.5 0 0 0 3 0v-7l-3-3M4 20v-14a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v14M3 20h12M18 7v1a1 1 0 0 0 1 1h1M4 11h10"/>',
  ),
  cylinder(
    r'<rect x="3" y="7" width="16" height="10" rx="5"/><path d="M19 10h2v4h-2M8 7v10M14 7v10"/>',
  ),
  chip(
    r'<rect x="5" y="5" width="14" height="14" rx="2"/><path d="M9 9h6v6h-6zM3 10h2M3 14h2M10 3v2M14 3v2M21 10h-2M21 14h-2M14 21v-2M10 21v-2"/>',
  ),
  calendar(
    r'<rect x="4" y="5" width="16" height="16" rx="2"/><path d="M16 3v4M8 3v4M4 11h16"/>',
  ),
  gauge(
    r'<circle cx="12" cy="12" r="9"/><path d="M13.41 10.59l2.59-2.59M7 12a5 5 0 0 1 5-5"/><circle cx="12" cy="12" r="1.5"/>',
  ),
  wind(
    r'<path d="M5 8h8.5a2.5 2.5 0 1 0-2.34-3.24M3 12h15.5a2.5 2.5 0 1 1-2.34 3.24M4 16h5.5a2.5 2.5 0 1 1-2.34 3.24"/>',
  ),
  drop(
    r'<path d="M7.502 19.423c2.602 2.105 6.395 2.105 8.996 0c2.602-2.105 3.262-5.708 1.566-8.546l-4.89-7.26c-.42-.625-1.287-.803-1.936-.397a1.376 1.376 0 0 0-.41.397l-4.893 7.26c-1.695 2.838-1.035 6.441 1.567 8.546z"/>',
  ),
  exit(
    r'<path d="M13 12v.01M3 21h18M5 21v-16a2 2 0 0 1 2-2h7.5M17 13.5v7.5M14 7h7M18 4l3 3l-3 3"/>',
  ),
  key(
    r'<circle cx="8" cy="15" r="4"/><path d="M10.85 12.15l8.15-8.15M18 5l2 2M15 8l2 2"/>',
  ),
  noSmoke(
    r'<path d="M8 13h-5v3h8M16 13h5v3h-2M3 3l18 18M16 5c0 2 2 2 2 4M19 5c0 2 2 2 2 4"/>',
  ),
  share(
    r'<circle cx="6" cy="12" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="18" cy="18" r="3"/><path d="M8.7 10.7l6.6-3.4M8.7 13.3l6.6 3.4"/>',
  ),
  user(
    r'<circle cx="12" cy="7" r="4"/><path d="M6 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/>',
  ),
  building(
    r'<path d="M3 21h18M5 21v-14l8-4v18M19 21v-10l-6-4M9 9v.01M9 12v.01M9 15v.01M9 18v.01"/>',
  );

  const AppIcon(this.markup);
  final String markup;
}

/// Dibuja un [AppIcon] con el trazo, tamaño y color indicados.
class AppIconView extends StatelessWidget {
  const AppIconView(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.9,
    this.filled = false,
    this.solid = false,
    this.fillColor,
  });

  final AppIcon icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Relleno del color del trazo (ícono activo de la barra de navegación).
  final bool filled;

  /// Sin trazo y con relleno (estrellas).
  final bool solid;

  /// Relleno de otro color que el trazo (pin del chip «San Isidro»).
  final Color? fillColor;

  static String _hex(Color c) {
    final rgb = c.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    final hex = _hex(c);
    final op = c.a;
    final opacity = op < 1 ? ' opacity="${op.toStringAsFixed(3)}"' : '';
    final String svg;
    if (solid) {
      svg =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$hex" stroke="none"$opacity>${icon.markup}</svg>';
    } else {
      svg =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="${fillColor != null ? _hex(fillColor!) : (filled ? hex : 'none')}" stroke="$hex" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round"$opacity>${icon.markup}</svg>';
    }
    return SvgPicture.string(svg, width: size, height: size);
  }
}
