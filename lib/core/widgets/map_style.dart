/// Estilo claro de Google Maps (mismo aire que el mapa del prototipo):
/// sin comercios ni transporte, calles blancas y parques suaves.
const kLightMapStyle = '''
[
 {"elementType":"geometry","stylers":[{"color":"#f3f4f6"}]},
 {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#a7acb5"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"}]},
 {"featureType":"poi","stylers":[{"visibility":"off"}]},
 {"featureType":"poi.park","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#d5ecd8"}]},
 {"featureType":"transit","stylers":[{"visibility":"off"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
 {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
 {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f7e9be"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#dbe7f3"}]}
]
''';
