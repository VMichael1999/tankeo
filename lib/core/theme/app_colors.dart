import 'package:flutter/painting.dart';

/// Paleta completa de Tankeo. Es el único lugar de la app donde se escriben
/// colores literales; el resto del código usa estas constantes o los tokens.
abstract final class AppColors {
  // Marca y combustibles
  static const primary = Color(0xFFF2620F);
  static const primaryLight = Color(0xFFFF8A3D);
  static const primaryMid = Color(0xFFFF9A52);
  static const primarySoft = Color(0xFFFFF0E6);
  static const primaryTint = Color(0xFFFFF8F2);
  static const primaryTrack = Color(0xFFFDE9DA);
  static const primaryTrack2 = Color(0xFFFBD3B5);
  static const primaryAvatar = Color(0xFFFFEBDD);
  static const primaryBorder = Color(0xFFF9B98B);
  static const gnv = Color(0xFF0F9F8F);
  static const gnvSoft = Color(0xFFE3F6F3);
  static const gnvTrack = Color(0xFFB8ECE4);
  static const premium = Color(0xFFB91C1C);
  static const diesel = Color(0xFF374151);

  // Textos
  static const ink = Color(0xFF0F1115);
  static const ink2 = Color(0xFF6B7280);
  static const ink3 = Color(0xFF9CA3AF);
  static const inkBody = Color(0xFF3A3F4A);
  static const inkField = Color(0xFF596579);

  // Superficies
  static const bg = Color(0xFFEFF1F4);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFEDEFF2);
  static const lineSoft = Color(0xFFEEF0F3);
  static const chipBorder = Color(0xFFE3E6EA);
  static const lineChip = Color(0xFFE7E9ED);
  static const navPill = Color(0xFF141518);
  static const grayChip = Color(0xFFF3F4F6);
  static const grayTile = Color(0xFFF5F6F8);
  static const warmTile = Color(0xFFF5F2EF);
  static const grab = Color(0xFFE5E7EB);
  static const progressTrack = Color(0xFFF1F2F4);
  static const checkBorder = Color(0xFFD1D5DB);
  static const switchOff = Color(0xFFD1D5DB);
  static const barTrack = Color(0xFFEEF0F3);
  static const ratingTrack = Color(0xFFE3E5E9);
  static const ratingFill = Color(0xFF16181D);
  static const starOn = Color(0xFFF5A524);
  static const starOff = Color(0xFFD7DAE0);
  static const vesselCap = Color(0xFFE2E8F0);

  // Estados
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFE7F7EE);
  static const successLight = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const dangerSoft = Color(0xFFFEECEC);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF3C7);

  // Llegada al grifo (tintes suaves)
  static const arrivalMint = Color(0xFF86EFAC);
  static const arrivalPumpText = Color(0xFFFDBA8C);
  static const arrivalGrab = Color(0xFFE1E4E8);
  static const arrivalChipBg = Color(0xFFF0F7F2);
  static const arrivalChipText = Color(0xFF15803D);
  static const arrivalChipDot = Color(0xFF22A35A);
  static const arrivalDivider = Color(0xFFE6E8EC);
  static const arrivalCardBorder = Color(0xFFECEEF1);
  static const arrivalPumpBg = Color(0xFFFFF3EB);

  // Barra de pestañas (vidrio estilo iOS)
  static const tabGlass = Color(0xFFFAFAFC);
  static const tabGlassDark = Color(0xFF1C1C1E);
  static const tabInactive = Color(0xFF3C3F46);
  static const tabInactiveDark = Color(0xFFE5E5EA);

  // Navegación en marcha
  static const routeDone = Color(0xFFB9BEC7);
  static const speedLimitRing = Color(0xFFDC2626);

  // Rellenos del auto y recipientes
  static const gasFillA = Color(0xFFFFB067);
  static const gasFillB = Color(0xFFF2620F);
  static const gasFillC = Color(0xFFC2410C);
  static const gasVesselTop = Color(0xFFFF9A52);
  static const gasVesselCap = Color(0xFFFFC08A);
  static const gasEdge = Color(0xFFFFD9B8);
  static const gasEdgeGlow = Color(0xFFFFB37A);
  static const gnvFillA = Color(0xFF5EEAD4);
  static const gnvFillB = Color(0xFF14B8A6);
  static const gnvFillC = Color(0xFF0F766E);
  static const gnvVesselCap = Color(0xFF99F0E2);

  // Pantalla del surtidor (LCD)
  static const lcdTop = Color(0xFF121614);
  static const lcdBottom = Color(0xFF0B0E0C);
  static const lcdAmber = Color(0xFFFFB25B);
  static const lcdTeal = Color(0xFF5EEAD4);

  // Degradados de fondo
  static const splashA = Color(0xFF2A1609);
  static const splashB = Color(0xFF140B05);
  static const splashC = Color(0xFF080403);
  static const loginHeroA = Color(0xFF3A1D0C);
  static const loginHeroB = Color(0xFF1C0F07);
  static const loginHeroC = Color(0xFF0D0704);
  static const loginBg = Color(0xFFF4F5F8);
  static const loginSheet = Color(0xFFF6F7F9);
  static const homeHdrA = Color(0xFF0A0B0E);
  static const homeHdrB = Color(0xFF131418);
  static const detailDark = Color(0xFF0C0D10);
  static const receiptA = Color(0xFF24140A);
  static const receiptB = Color(0xFF170C06);
  static const receiptC = Color(0xFF0B0603);
  static const mapChip = Color(0xFF121316);
  static const pinPill = Color(0xFF15171C);

  // Comprobante
  static const paper = Color(0xFFFBFAF5);
  static const paperInk = Color(0xFF1A1A1A);
  static const paperMuted = Color(0xFF555555);
  static const paperFaint = Color(0xFF777777);
  static const paperDash = Color(0xFFBDBDB5);
  static const paperRule = Color(0xFF222222);
  static const paperSon = Color(0xFF333333);
  static const paperQr = Color(0xFF111111);
  static const stamp = Color(0xFFD94E06);
  static const printerTop = Color(0xFFF6F7FA);
  static const printerBottom = Color(0xFFD5D9E2);
  static const printerEdge = Color(0xFFB9BFCB);
  static const printerSlot = Color(0xFF0B0D14);

  // Pagos y redes
  static const yapeBg = Color(0xFFF1EAFB);
  static const yapeFg = Color(0xFF6B2BB8);
  static const visaFg = Color(0xFF1A1F71);

  // Mapa
  static const mapBase = Color(0xFFFAFAFB);
  static const mapBlockA = Color(0xFFE7E8EB);
  static const mapBlockB = Color(0xFFE2E3E7);
  static const mapPark = Color(0xFFD5ECD8);
  static const mapRoadOuter = Color(0xFFF1DC9C);
  static const mapRoadInner = Color(0xFFF7E9BE);
  static const mapLabel = Color(0xFFA7ACB5);
  static const mapViewport = Color(0xFFEEEFF1);
  static const miniMapBase = Color(0xFFEEF0F3);
  static const miniMapBlock = Color(0xFFE3E6EA);

  // Ilustración del grifo y del surtidor
  static const stationSky = Color(0xFFF3EEE9);
  static const stationFloor = Color(0xFFE4DDD5);
  static const stationLane = Color(0xFFD6CDC3);
  static const stationRoof = Color(0xFF1A1512);
  static const stationPillar = Color(0xFFCFC6BC);
  static const pumpBody = Color(0xFFFFFFFF);
  static const pumpStroke = Color(0xFFDDD4CA);
  static const pumpScreen = Color(0xFF15110E);
  static const pumpBase = Color(0xFFC9BFB4);
  static const pumpPole = Color(0xFF5A4E44);
  static const pinStroke = Color(0xFFD8CFC6);
  static const loginPump = Color(0xFFEFE9E3);
  static const loginPumpBase = Color(0xFFC9C1B8);
  static const hose = Color(0xFF1B1E25);
  static const thumbBg = Color(0xFFE9EEF6);

  // Varios
  static const scrim = Color(0xFF0F1115);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const stripe = Color(0xFFFFFFFF);
  static const pctShadow = Color(0xFF001E5A);
}
