import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Minimapa de la tarjeta «Encuentra el grifo más barato» (230 × 170).
class MiniMap extends StatelessWidget {
  const MiniMap({super.key});

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 230 170">
  <defs><linearGradient id="fade" x1="0" x2="1" y1="0" y2="0"><stop offset="0" stop-color="#fff"/><stop offset=".35" stop-color="#fff" stop-opacity="0"/></linearGradient></defs>
  <rect width="230" height="170" fill="#EEF0F3"/>
  <g stroke="#fff" stroke-width="7"><path d="M0 40h230M0 95h230M0 145h230M40 0v170M100 0v170M160 0v170M210 0v170"/></g>
  <g fill="#E3E6EA"><rect x="112" y="50" width="40" height="38" rx="3"/><rect x="170" y="105" width="34" height="34" rx="3"/></g>
  <path d="M95 140h65v-75h35v-25" fill="none" stroke="#F2620F" stroke-width="7" stroke-linejoin="round"/>
  <circle cx="195" cy="40" r="12" fill="#F2620F"/>
  <path d="M190 46v-11a1.5 1.5 0 0 1 1.5-1.5h4a1.5 1.5 0 0 1 1.5 1.5v11M189 46h9M191 39h5M197 40h1.5a1 1 0 0 1 1 1v3a1 1 0 0 0 2 0v-5l-2-2" stroke="#fff" stroke-width="1.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <rect width="230" height="170" fill="url(#fade)"/>
</svg>''';

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_svg, width: 230, height: 170);
}
