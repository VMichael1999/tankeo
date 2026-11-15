# Tankeo

App en Flutter para encontrar el grifo más barato de Lima, cargar **gasolina o GNV** desde el auto, pagar con Yape, Plin o tarjeta y recibir la boleta o factura electrónica. Usuario de ejemplo: Michael Dev (michaeldev@gmail.com). Réplica del prototipo `tanqueo-prototipo.html`.

- Flutter 3.47.5 (`.fvmrc`), BLoC + go_router + get_it, textos en `lib/l10n/app_es.arb`.
- Navegación inferior con `liquid_glass_widgets` (`GlassTabBar.bottom`).
- Lienzo de diseño de 440 pt (`DesignCanvas`) para conservar las medidas del HTML en cualquier pantalla.

```bash
flutter pub get
flutter run
flutter run --dart-define=INITIAL_ROUTE=/summary   # abrir una pantalla directo
flutter test
python3 tool/gen_arb.py && flutter gen-l10n         # si cambias textos
```

Live Activity: `live_island_kit` (isla dinámica en iOS, Live Update en Android). Elige tu equipo en Xcode para correr en iPhone.

## Google Maps

La clave va en `.env` (copia `.env.example`): `EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=...`. Android la lee directo de `.env`; para iOS ejecuta una vez `./tool/sync_env.sh` (genera `ios/Flutter/Env.xcconfig`, ignorado por git). `.env` no se sube al repositorio.

## Pantallas y flujos incluidos

- **Auth:** splash, login, crear cuenta (3–4 pasos con validaciones), recuperar contraseña (código de 4 dígitos; `0000` falla en la demo).
- **Inicio / Carga / Grifos / Detalle / Resumen / Comprobante**, con cola en grifo lleno y los errores de certificación, surtidor y pago (panel «Simular errores» en el menú ⋯ de Carga).
- **Navegación hacia el grifo** (`NavigationBloc`): vista general → conducción 2D/3D → llegada. Desde el Detalle, «Ir a cargar».
- **Cuenta:** Ajustes (pestaña), Mis vehículos (+ agregar), Métodos de pago (+ tarjeta con Luhn), Datos de facturación, Historial (comprobantes guardados), Notificaciones, Certificación GNV (+ agendar renovación) y Puntos (canjes).
- Las pantallas secundarias se abren con `context.push` y vuelven con `pop` al origen.

Notas: la ruta usa tramos rectos (sin Directions API) y el auto del mapa es la foto cenital rotada (no hay modelo 3D).

## Modelo 3D del auto

En la navegación, cuando el mapa pasa a 3D el auto se muestra con el modelo `assets/models/car.glb`
(visor `model-viewer` transparente sobre el mapa; en 2D se usa la foto cenital).

Crédito: «McLaren F1 1993 by Alex.Ka.» de Alex.Ka. en [Sketchfab](https://sketchfab.com/3d-models/mclaren-f1-1993-by-alexka-294df724d96241cdbe0e0f3c91ad7fce),
licencia **CC BY-NC 4.0** (solo uso no comercial; hay que dar crédito). El archivo está optimizado
(sin planos de suelo, texturas a 1024 px, malla simplificada: 12.7 MB → 1.8 MB).
