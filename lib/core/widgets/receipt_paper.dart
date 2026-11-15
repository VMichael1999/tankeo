import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../features/payment/domain/tax_document.dart';
import '../../features/payment/domain/tax_document_strategy.dart';
import '../domain/fuel_type.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';
import '../utils/spanish_amount_words.dart';
import '../utils/volume_format.dart';

/// Papel térmico del comprobante: empresa, serie y número, datos, tabla de
/// ítems, op. gravada, IGV, total, importe en letras, forma de pago, QR y el
/// sello «PAGADO» a la izquierda del QR.
class ReceiptPaper extends StatelessWidget {
  const ReceiptPaper({
    super.key,
    required this.document,
    required this.stamped,
  });

  final TaxDocument document;
  final bool stamped;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = document;
    final r = d.result;
    final issuer = d.issuer;
    final boleta = d.type == TaxDocumentType.boleta;
    final ink = AppText.mono(
      11,
      AppText.w5,
      color: AppColors.paperInk,
      height: 1.65,
    );
    final label = ink.copyWith(color: AppColors.paperMuted);
    Widget row(String k, String v) => Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.toUpperCase(), style: label),
          const SizedBox(width: 10),
          Flexible(
            child: Text(v, textAlign: TextAlign.right, style: ink),
          ),
        ],
      ),
    );
    final date = DateFormat('dd/MM/yyyy HH:mm').format(d.issuedAt);
    final stampDate = DateFormat(
      'd MMM yyyy',
      'es',
    ).format(d.issuedAt).replaceAll('.', '').toUpperCase();
    final product = r.fuel.isGnv
        ? l.fuelGnv
        : (r.fuel == FuelType.premium ? l.fuelPremiumLong : l.fuelRegularLong);
    final tb = AppText.mono(
      10.5,
      AppText.w4,
      color: AppColors.paperInk,
      height: 1.6,
    );

    Widget cells(List<String> c, TextStyle style) => Row(
      children: [
        Expanded(child: Text(c[0], style: style)),
        SizedBox(
          width: 62,
          child: Text(c[1], textAlign: TextAlign.right, style: style),
        ),
        SizedBox(
          width: 44,
          child: Text(c[2], textAlign: TextAlign.right, style: style),
        ),
        SizedBox(
          width: 54,
          child: Text(c[3], textAlign: TextAlign.right, style: style),
        ),
      ],
    );

    return ClipPath(
      clipper: const _TornEdgeClipper(),
      child: Container(
        color: AppColors.paper,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  issuer.company,
                  textAlign: TextAlign.center,
                  style: AppText.ui(
                    13.5,
                    AppText.w8,
                    color: AppColors.paperInk,
                    letterSpacing: 13.5 * .02,
                  ),
                ),
                Text(
                  'RUC ${issuer.ruc}\n${issuer.address}, ${issuer.district}',
                  textAlign: TextAlign.center,
                  style: AppText.mono(
                    9.5,
                    AppText.w4,
                    color: AppColors.paperMuted,
                    height: 1.5,
                  ),
                ),
                const _Dash(),
                Text(
                  boleta ? l.receiptBoletaTitle : l.receiptFacturaTitle,
                  textAlign: TextAlign.center,
                  style: AppText.mono(
                    11.5,
                    AppText.w6,
                    color: AppColors.paperInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.number,
                  textAlign: TextAlign.center,
                  style: AppText.mono(
                    11.5,
                    AppText.w6,
                    color: AppColors.paperInk,
                  ),
                ),
                const _Dash(),
                row(l.receiptDate, date),
                row(boleta ? l.fieldDni : l.fieldRuc, d.customer.id),
                if (!boleta) row(l.fieldBusinessName, d.customer.name),
                row(l.receiptPump, issuer.assignedPump.toUpperCase()),
                const _Dash(),
                cells([
                  l.receiptDescription,
                  l.receiptQty,
                  l.receiptUnitPrice,
                  l.receiptAmount,
                ], tb.copyWith(color: AppColors.paperMuted)),
                const _Dash(vertical: 2),
                cells([
                  product.toUpperCase(),
                  '${VolumeFormat.d3(r.volume)} ${r.fuel.unit}',
                  Money.plain(r.price),
                  Money.plain(r.total),
                ], tb),
                const _Dash(),
                row(l.receiptTaxable, Money.format(d.amounts.opGravada)),
                row(l.receiptIgv, Money.format(d.amounts.igv)),
                const SizedBox(height: 10),
                const ColoredBox(
                  color: AppColors.paperRule,
                  child: SizedBox(height: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l.receiptTotal,
                      style: AppText.mono(
                        13,
                        AppText.w6,
                        color: AppColors.paperInk,
                      ),
                    ),
                    Text(
                      Money.format(d.amounts.total),
                      style: AppText.ui(
                        26,
                        AppText.w8,
                        color: AppColors.paperInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  SpanishAmountWords.son(d.amounts.total),
                  style: AppText.mono(
                    10,
                    AppText.w4,
                    color: AppColors.paperSon,
                  ),
                ),
                const SizedBox(height: 6),
                row(l.receiptPaymentMethod, d.method.receiptLabel),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: d.qrPayload,
                    size: 84,
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.paper,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.paperQr,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.paperQr,
                    ),
                    semanticsLabel: l.receiptQrSemantic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.receiptLegal,
                  textAlign: TextAlign.center,
                  style: AppText.mono(
                    8.5,
                    AppText.w4,
                    color: AppColors.paperFaint,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            Positioned(
              left: -6,
              bottom: 24,
              child: _Stamp(
                visible: stamped,
                date: stampDate,
                label: l.receiptPaid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash({this.vertical = 10});

  final double vertical;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: vertical),
    child: const SizedBox(
      height: 1.5,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter()),
    ),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.paperDash
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, .75), Offset(x + 3.5, .75), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => false;
}

/// Borde inferior en dientes (`conic-gradient` de 16 × 12 del prototipo):
/// puntas hacia abajo cada 16 px con 8 px de profundidad.
class _TornEdgeClipper extends CustomClipper<Path> {
  const _TornEdgeClipper();

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    double yAt(double x) {
      final t = x % 16;
      return t <= 8 ? h - 8 + t : h - (t - 8);
    }

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, yAt(w));
    for (var i = (w / 16).floor(); i >= 0; i--) {
      final x0 = i * 16.0;
      final xc = x0 + 8;
      if (xc < w) path.lineTo(xc, h);
      if (x0 < w) path.lineTo(x0, h - 8);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TornEdgeClipper old) => false;
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.visible,
    required this.date,
    required this.label,
  });

  final bool visible;
  final String date;
  final String label;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.8, end: visible ? 1 : 1.8),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 250),
        curve: const Cubic(.2, 1.6, .4, 1),
        builder: (context, scale, child) => Transform.rotate(
          angle: -12 * 3.1415926535 / 180,
          child: Transform.scale(scale: scale, child: child),
        ),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.stamp.withValues(alpha: .8),
              width: 3,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.stamp.withValues(alpha: .6),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppText.ui(
                    15,
                    AppText.w8,
                    color: AppColors.stamp.withValues(alpha: .9),
                    letterSpacing: 15 * .06,
                    height: 1.2,
                  ),
                ),
                Text(
                  date,
                  style: AppText.mono(
                    7,
                    AppText.w4,
                    color: AppColors.stamp.withValues(alpha: .9),
                    letterSpacing: .7,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
