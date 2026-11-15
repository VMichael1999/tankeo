import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Auto en 3D (glTF) visto desde atrás con la misma inclinación que el mapa.
///
/// Es un visor `model-viewer` transparente que se coloca encima del mapa,
/// porque los marcadores de Google Maps solo aceptan imágenes. [yaw] (grados)
/// gira el auto sobre su eje vertical para que «tome» las curvas.
class Car3D extends StatefulWidget {
  const Car3D({
    super.key,
    required this.yaw,
    required this.onReady,
    this.tilt = 52,
  });

  final ValueNotifier<double> yaw;
  final VoidCallback onReady;

  /// Ángulo de la cámara desde la vertical (el `tilt` del mapa).
  final double tilt;

  static const asset = 'assets/models/car.glb';

  @override
  State<Car3D> createState() => _Car3DState();
}

class _Car3DState extends State<Car3D> {
  WebViewController? _web;
  double _sent = 0;

  @override
  void initState() {
    super.initState();
    widget.yaw.addListener(_applyYaw);
  }

  @override
  void dispose() {
    widget.yaw.removeListener(_applyYaw);
    super.dispose();
  }

  /// Pregunta cada 0.4 s si el modelo ya cargó (máx. ~20 s).
  Future<void> _pollLoaded() async {
    for (var i = 0; i < 50 && mounted; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      try {
        final r = await _web?.runJavaScriptReturningResult(
          "document.querySelector('#car') && document.querySelector('#car').loaded",
        );
        if (r.toString() == 'true' || r.toString() == '1') {
          if (mounted) widget.onReady();
          return;
        }
      } on Object {
        // La página aún no está lista.
      }
    }
  }

  void _applyYaw() {
    final y = widget.yaw.value;
    if ((y - _sent).abs() < 1.2) return;
    _sent = y;
    _web?.runJavaScript(
      "document.querySelector('#car').orientation='0deg 0deg ${y.toStringAsFixed(1)}deg';",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ModelViewer(
        id: 'car',
        src: Car3D.asset,
        alt: '',
        backgroundColor: Colors.transparent,
        cameraControls: false,
        disableZoom: true,
        disablePan: true,
        disableTap: true,
        interactionPrompt: InteractionPrompt.none,
        cameraOrbit: '180deg ${widget.tilt.round()}deg auto',
        fieldOfView: '28deg',
        environmentImage: 'neutral',
        exposure: 1.05,
        // Sin barra de progreso ni póster: el auto aparece cuando cargó.
        relatedCss: 'model-viewer::part(default-progress-bar){display:none}',
        loading: Loading.eager,
        reveal: Reveal.auto,
        onWebViewCreated: (c) {
          _web = c;
          _pollLoaded(); // respaldo si el aviso del canal no llega
        },
        javascriptChannels: {
          JavascriptChannel(
            'Ready',
            onMessageReceived: (_) {
              widget.onReady();
            },
          ),
        },
        relatedJs: "document.querySelector('#car').addEventListener('load', () => Ready.postMessage('1'));",
      ),
    );
  }
}
