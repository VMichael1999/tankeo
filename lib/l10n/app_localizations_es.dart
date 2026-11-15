// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'TANKEO';

  @override
  String get splashTagline => 'CARGA RÁPIDO  ·  PAGA DESDE TU AUTO';

  @override
  String get carSemantic => 'McLaren F1';

  @override
  String get carSemanticYear => 'McLaren F1 1993';

  @override
  String get loginTitle => 'Inicia sesión';

  @override
  String get loginSubtitle =>
      '¡Hola de nuevo! Ingresa para cargar sin bajarte del auto.';

  @override
  String get loginEmailHint => 'Correo electrónico';

  @override
  String get loginPasswordHint => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginForgot => '¿Olvidaste tu contraseña?';

  @override
  String get loginSubmit => 'Ingresar';

  @override
  String get loginOr => 'O ingresa con';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get loginRegister => 'Regístrate';

  @override
  String get navCar => 'Auto';

  @override
  String get navCharge => 'Carga';

  @override
  String get navStations => 'Grifos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String greetingMorning(String name) {
    return 'Buenos días,\n$name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Buenas tardes,\n$name';
  }

  @override
  String greetingEvening(String name) {
    return 'Buenas noches,\n$name';
  }

  @override
  String get homeCarSubtitle => 'McLaren F1 1993 · Dual gasolina + GNV';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get homeFuelTitle => 'Combustible';

  @override
  String get homeLastCharge => 'Última carga hace 2 días';

  @override
  String homeVolumeOf(String current, String capacity, String unit) {
    return '$current de $capacity $unit';
  }

  @override
  String get fuelGasoline => 'Gasolina';

  @override
  String get fuelGnv => 'GNV';

  @override
  String get homeTotalRange => 'Autonomía total';

  @override
  String kmValue(int count) {
    return '$count km';
  }

  @override
  String odometerValue(String km) {
    return '$km km';
  }

  @override
  String get homeOdometer => 'Kilometraje';

  @override
  String get homeCheapestGnv => 'GNV más barato cerca';

  @override
  String get homeFindCheapest => 'Encuentra el grifo más barato';

  @override
  String get homeSeeStations => 'Ver grifos';

  @override
  String etaMinKm(int minutes, String km) {
    return '$minutes min · $km km';
  }

  @override
  String get homeQuickControls => 'Controles rápidos';

  @override
  String get homeEdit => 'Editar';

  @override
  String get controlDoors => 'Puertas';

  @override
  String get controlDoorsOn => 'Cerradas';

  @override
  String get controlDoorsOff => 'Abiertas';

  @override
  String get controlGnvOn => 'Activo';

  @override
  String get controlGnvOff => 'Gasolina';

  @override
  String get controlLights => 'Luces';

  @override
  String get controlLightsOn => 'Encendidas';

  @override
  String get controlLightsOff => 'Apagadas';

  @override
  String get controlCap => 'Tapa';

  @override
  String get controlCapOn => 'Abierta';

  @override
  String get controlCapOff => 'Cerrada';

  @override
  String get certTitle => 'Certificación GNV';

  @override
  String certSubtitle(String cylinder) {
    return 'Chip Infogas activo · Cilindro $cylinder';
  }

  @override
  String get certValid => 'Vigente';

  @override
  String get certAnnualExpires => 'Anual vence';

  @override
  String get certDays => 'días';

  @override
  String certReview(String date) {
    return 'Revisión del cilindro (cada 4 años): $date';
  }

  @override
  String get spendTitle => 'Gasto esta semana';

  @override
  String spendSaved(String amount) {
    return 'Ahorraste $amount';
  }

  @override
  String get spendWithGnv => 'usando GNV';

  @override
  String get weekdayInitials => 'D,L,M,M,J,V,S';

  @override
  String get tiresTitle => 'Presión de llantas';

  @override
  String get tiresLowFrontLeft => 'Delantera izq. baja';

  @override
  String get tiresCarSemantic => 'Auto visto desde arriba';

  @override
  String get psi => 'psi';

  @override
  String tireLowTemp(int temp) {
    return 'Baja · $temp°C';
  }

  @override
  String tireTemp(int temp) {
    return '$temp°C';
  }

  @override
  String get gnvSavingsValue => '52%';

  @override
  String get gnvSavingsLabel => 'Ahorro con GNV';

  @override
  String get gnvEfficiencyValue => '13 km/m³';

  @override
  String get gnvEfficiencyLabel => 'Rendimiento GNV';

  @override
  String get fuelRegular => 'Regular';

  @override
  String get fuelPremium => 'Premium';

  @override
  String get fuelDiesel => 'Diésel B5';

  @override
  String get fuelRegularLong => 'Gasohol Regular';

  @override
  String get fuelPremiumLong => 'Gasohol Premium';

  @override
  String get mapTitle => 'Grifos cercanos';

  @override
  String get filters => 'Filtros';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Alejar';

  @override
  String get centerOnCar => 'Centrar en mi auto';

  @override
  String get mapLocation => 'San Isidro, Lima';

  @override
  String get cheapestTag => 'Más barato';

  @override
  String get pumpsAllBusy => 'Todos ocupados';

  @override
  String pumpsFree(int free, int total) {
    return '$free/$total libres';
  }

  @override
  String pumpsFreeShort(int free, int total) {
    return '$free/$total libres';
  }

  @override
  String ratingLine(String rating, int minutes, String km) {
    return '$rating · $minutes min · $km km';
  }

  @override
  String get addressLabel => 'Dirección';

  @override
  String get share => 'Compartir';

  @override
  String get viewDetail => 'Ver detalle';

  @override
  String get detailTitle => 'Detalle';

  @override
  String get save => 'Guardar';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get detailSummary => 'Resumen';

  @override
  String get open24h => 'Abierto 24 h';

  @override
  String get open24hLong => 'Abierto 24 horas';

  @override
  String get detailPumps => 'Surtidores';

  @override
  String get detailGnvChip => 'Chip GNV';

  @override
  String get detailInfogasOnline => 'Infogas en línea';

  @override
  String get detailPayInApp => 'Pago en app';

  @override
  String get detailPayMethods => 'Yape · Plin · Tarjeta';

  @override
  String get detailTodayPrices => 'Precios de hoy';

  @override
  String get pricesIncludeIgv =>
      'Precios incluyen IGV. Compáralos también en Facilito de Osinergmin.';

  @override
  String get detailPumpsTitle => 'Surtidores';

  @override
  String get detailServices => 'Servicios';

  @override
  String get amenityStore => 'Tienda';

  @override
  String get amenityRestrooms => 'Baños';

  @override
  String get amenityAir => 'Aire';

  @override
  String get amenityWash => 'Lavado';

  @override
  String get amenityAtm => 'Cajero';

  @override
  String get amenitySecurity => 'Vigilancia 24/7';

  @override
  String get detailReviews => 'Reseñas';

  @override
  String get seeAll => 'Ver todo';

  @override
  String reviewCount(int count) {
    return '$count reseñas';
  }

  @override
  String get reviewer1Name => 'Lucía Quispe';

  @override
  String get reviewer1When => 'hace 2 días';

  @override
  String get reviewer1Text =>
      'Cargo GNV aquí todos los días con el taxi. Rápido, leen el chip al toque y pago con Yape desde el auto.';

  @override
  String get reviewer2Name => 'Jorge Ramírez';

  @override
  String get reviewer2When => 'hace 1 semana';

  @override
  String get reviewer2Text =>
      'Buen precio en Regular. En hora punta (7 a 9 am) se forma cola en las islas de GNV.';

  @override
  String get detailDistance => 'Distancia';

  @override
  String get detailByCar => 'En auto';

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String detailFillEstimate(String amount, String fuel) {
    return '≈ $amount para llenar $fuel';
  }

  @override
  String get goToCharge => 'Ir a cargar';

  @override
  String get pumpFree => 'Libre';

  @override
  String get pumpBusy => 'Ocupado';

  @override
  String get pumpFuelsGnv => 'GNV · R · P';

  @override
  String get pumpFuelsLiquid => 'R · P · D';

  @override
  String get location => 'Ubicación';

  @override
  String pumpLabel(String pump) {
    return 'Surtidor $pump';
  }

  @override
  String get tankGnvTitle => 'Cilindro GNV';

  @override
  String get tankGasolineTitle => 'Tanque de gasolina';

  @override
  String get chipInfogas => 'Chip Infogas';

  @override
  String get chipValidated => 'Chip validado';

  @override
  String levelVolume(String volume, String unit) {
    return 'Nivel · $volume $unit';
  }

  @override
  String get rangeGnv => 'Autonomía GNV';

  @override
  String get rangeGasoline => 'Autonomía gasolina';

  @override
  String get chargeHowMuch => '¿Cuánto cargar?';

  @override
  String get chargeFull => 'Lleno';

  @override
  String chargeFits(String volume, String unit) {
    return 'Caben $volume $unit';
  }

  @override
  String chargeAuthorize(String pump) {
    return 'Autorizar surtidor $pump';
  }

  @override
  String get chargeValidatingChip => 'Validando chip Infogas…';

  @override
  String get chargeConnecting => 'Conectando con el surtidor…';

  @override
  String get chargeViewPump => 'Ver surtidor';

  @override
  String chargePay(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get sheetDispensing => 'Despachando';

  @override
  String get sheetComplete => 'Carga completa';

  @override
  String get sheetHungUp => 'Manguera colgada';

  @override
  String sheetSubtitle(String station, String pump) {
    return '$station · Surtidor $pump';
  }

  @override
  String get minimize => 'Minimizar';

  @override
  String get lcdProductGnv => 'GNV · MANGUERA 2';

  @override
  String lcdProductGasoline(String product) {
    return '$product · MANGUERA 1';
  }

  @override
  String get lcdStatusRunning => 'EN CURSO';

  @override
  String get lcdStatusCompleted => 'COMPLETADO';

  @override
  String get lcdStatusHungUp => 'COLGADA';

  @override
  String get lcdStatusReady => 'LISTO';

  @override
  String get lcdAmount => 'IMPORTE S/';

  @override
  String lcdVolume(String unit) {
    return 'VOLUMEN $unit';
  }

  @override
  String lcdPrice(String unit) {
    return 'PRECIO S/ / $unit';
  }

  @override
  String get levelWord => 'Nivel';

  @override
  String get rangeWord => 'Autonomía';

  @override
  String get timeWord => 'Tiempo';

  @override
  String progressRemaining(String amount) {
    return 'Faltan $amount';
  }

  @override
  String progressTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get sheetDispensingEllipsis => 'Despachando…';

  @override
  String sheetAddedProgress(String volume, String unit) {
    return '+$volume $unit cargados';
  }

  @override
  String sheetAddedDone(String volume, String unit, String amount) {
    return '+$volume $unit · $amount';
  }

  @override
  String get hintStill =>
      'No muevas el auto ni enciendas el motor hasta colgar la manguera.';

  @override
  String get hintGnv =>
      'No muevas el auto ni enciendas el motor hasta colgar la manguera. Presión del cilindro: 200 bar.';

  @override
  String get hintHangUp =>
      'Cuelga la manguera para cerrar la carga y generar tu comprobante.';

  @override
  String get sheetStop => 'Detener';

  @override
  String get sheetHangUp => 'Colgar manguera';

  @override
  String get safetyTitle => 'Antes de cargar GNV';

  @override
  String get safetySubtitle => 'Confirma las medidas de seguridad del grifo.';

  @override
  String get safetyPassengersOut => 'Pasajeros fuera del vehículo';

  @override
  String get safetyEngineOff => 'Motor y celular apagados';

  @override
  String get safetyNoSmoking => 'Nadie fuma cerca del surtidor';

  @override
  String get cancel => 'Cancelar';

  @override
  String get safetyStart => 'Iniciar carga';

  @override
  String get back => 'Volver';

  @override
  String get summaryTitle => 'Resumen de carga';

  @override
  String get summaryDone => 'Carga completada';

  @override
  String get summaryDoneSub => 'Manguera colgada · listo para seguir';

  @override
  String get summaryLoaded => 'cargado';

  @override
  String get summaryBefore => 'Antes';

  @override
  String get summaryNow => 'Ahora';

  @override
  String get summaryVolume => 'Volumen';

  @override
  String get summaryStation => 'Grifo';

  @override
  String get summaryDate => 'Fecha';

  @override
  String get summaryPump => 'Surtidor';

  @override
  String get summaryIgv => 'IGV (18%)';

  @override
  String get receiptTaxable => 'Op. gravada';

  @override
  String get receiptTotalWord => 'Total';

  @override
  String get summaryDocument => 'Comprobante';

  @override
  String get summaryPaymentMethod => 'Medio de pago';

  @override
  String get summaryPay => 'Pagar';

  @override
  String get documentBoleta => 'Boleta';

  @override
  String get documentFactura => 'Factura';

  @override
  String get documentBoletaLower => 'boleta';

  @override
  String get documentFacturaLower => 'factura';

  @override
  String get fieldDni => 'DNI';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldRuc => 'RUC';

  @override
  String get fieldBusinessName => 'Razón social';

  @override
  String get paymentVisaCard => 'Tarjeta Visa';

  @override
  String get confirmTitle => 'Confirmar pago';

  @override
  String get confirmPayWith => 'Pagar con';

  @override
  String get confirmDocument => 'Comprobante';

  @override
  String get confirmProduct => 'Producto';

  @override
  String confirmBoleta(String id) {
    return 'Boleta · DNI $id';
  }

  @override
  String confirmFactura(String id) {
    return 'Factura · RUC $id';
  }

  @override
  String get confirmYes => 'Sí, pagar';

  @override
  String get processingTitle => 'Procesando pago';

  @override
  String processingSubtitle(String amount, String method) {
    return '$amount con $method';
  }

  @override
  String get successTitle => '¡Pago exitoso!';

  @override
  String successSubtitle(String amount, String method) {
    return '$amount pagado con $method';
  }

  @override
  String successPoints(int points) {
    return '+$points puntos Tankeo';
  }

  @override
  String successAsk(String document) {
    return '¿Quieres ver tu $document?';
  }

  @override
  String get successNo => 'No, gracias';

  @override
  String successView(String document) {
    return 'Ver $document';
  }

  @override
  String get receiptYourBoleta => 'Tu boleta';

  @override
  String get receiptYourFactura => 'Tu factura';

  @override
  String get receiptPrinting => 'Imprimiendo…';

  @override
  String receiptPaidWith(String amount, String method) {
    return '$amount pagado con $method';
  }

  @override
  String get receiptShare => 'Compartir';

  @override
  String get receiptDone => 'Listo';

  @override
  String get receiptBoletaTitle => 'BOLETA DE VENTA ELECTRÓNICA';

  @override
  String get receiptFacturaTitle => 'FACTURA ELECTRÓNICA';

  @override
  String get receiptDate => 'Fecha';

  @override
  String get receiptPump => 'Surtidor';

  @override
  String get receiptDescription => 'DESCRIPCIÓN';

  @override
  String get receiptQty => 'CANT.';

  @override
  String get receiptUnitPrice => 'P.U.';

  @override
  String get receiptAmount => 'IMPORTE';

  @override
  String get receiptIgv => 'IGV 18%';

  @override
  String get receiptTotal => 'IMPORTE TOTAL';

  @override
  String get receiptPaymentMethod => 'Forma de pago';

  @override
  String get receiptQrSemantic => 'Código QR del comprobante';

  @override
  String get receiptLegal =>
      'Representación impresa del comprobante electrónico.\nPrototipo Tankeo · datos de ejemplo, sin valor tributario.';

  @override
  String get receiptPaid => 'PAGADO';

  @override
  String get errRetry => 'Reintentar';

  @override
  String errPumpTitle(String pump) {
    return 'Sin conexión con el surtidor $pump';
  }

  @override
  String get errPumpBody =>
      'El surtidor no respondió. No se te cobró nada y la manguera sigue bloqueada.';

  @override
  String get errPumpOther => 'Usar otro surtidor';

  @override
  String get errCertTitle => 'Carga de GNV bloqueada';

  @override
  String get errCertBodyA =>
      'Infogas indica que la certificación anual de tu cilindro ';

  @override
  String errCertBodyB(String date) {
    return 'venció el $date';
  }

  @override
  String get errCertBodyC =>
      '. Renuévala en un taller autorizado para volver a cargar GNV.';

  @override
  String get errCertGasoline => 'Cargar gasolina';

  @override
  String get errCertView => 'Ver certificación';

  @override
  String get errPayTitle => 'Pago rechazado';

  @override
  String errPayBodyA(String method) {
    return '$method no autorizó el cargo de ';
  }

  @override
  String get errPayBodyC => '. No se te cobró nada.';

  @override
  String get errPayChange => 'Cambiar método';

  @override
  String get queueTitleBusy => 'Todos los surtidores están ocupados';

  @override
  String queueTitleReady(String pump) {
    return '¡Surtidor $pump libre!';
  }

  @override
  String queueSubWait(int min) {
    return 'Te avisamos apenas se libere uno. Espera aprox. $min min.';
  }

  @override
  String queueSubReady(String isle) {
    return 'Acércate a la $isle. Tienes 3 min para autorizar.';
  }

  @override
  String get queueInQueue => 'en la cola';

  @override
  String get queueYourTurn => 'te toca';

  @override
  String get queueAhead => 'Autos antes que tú';

  @override
  String get queueStation => 'Grifo';

  @override
  String get queueLeave => 'Salir de la cola';

  @override
  String get queueWaiting => 'Esperando…';

  @override
  String get queueGo => 'Ir al surtidor';

  @override
  String get simTitle => 'Simular errores';

  @override
  String get simCert => 'Certificación GNV vencida';

  @override
  String get simCertSub => 'bloquea la carga de GNV';

  @override
  String get simPump => 'Surtidor sin conexión';

  @override
  String get simPumpSub => 'una vez, al autorizar';

  @override
  String get simPay => 'Pago rechazado';

  @override
  String get simPaySub => 'una vez, al pagar';

  @override
  String get certExpiredBadge => 'Vencida';

  @override
  String get certExpiredOn => 'Anual venció';

  @override
  String get certRenew => 'Renovar';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterClear => 'Limpiar';

  @override
  String get filterFree => 'Con surtidores libres';

  @override
  String get filterFreeSub => 'Oculta los grifos llenos';

  @override
  String get filterApp => 'Pago desde la app';

  @override
  String get filterAppSub => 'Yape, Plin o tarjeta en el surtidor';

  @override
  String get filterDistance => 'Distancia máxima';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterServices => 'Servicios';

  @override
  String filterShow(int count, String stations) {
    return 'Mostrar $count $stations';
  }

  @override
  String get filterStationOne => 'grifo';

  @override
  String get filterStationMany => 'grifos';

  @override
  String get filterNone => 'Ningún grifo coincide';

  @override
  String toastFiltersCount(int count, String what) {
    return '$count $what';
  }

  @override
  String get toastFiltersMatchOne => 'grifo coincide.';

  @override
  String get toastFiltersMatchMany => 'grifos coinciden.';

  @override
  String get toastHiddenByFilters => 'Ese grifo está oculto por tus filtros.';

  @override
  String toastNewPump(String pump) {
    return 'Te asignamos el surtidor $pump.';
  }

  @override
  String get toastLeftQueue => 'Saliste de la cola.';

  @override
  String get toastPickAnotherMethod => 'Elige otro método y vuelve a pagar.';

  @override
  String get toastDieselInfo =>
      'Tu McLaren F1 no usa diésel: solo verás los precios.';

  @override
  String get toastFinishCurrentCharge =>
      'Termina tu carga actual antes de ir a otro grifo.';

  @override
  String get toastPayPreviousFirst => 'Primero paga tu carga anterior.';

  @override
  String toastArrived(String station, String pump) {
    return 'Llegaste a $station. Surtidor $pump asignado.';
  }

  @override
  String get toastGridBusy =>
      'Todos los surtidores están ocupados: espera aprox. 6 min.';

  @override
  String get toastChipValidated =>
      'Chip Infogas validado · cilindro con certificación vigente.';

  @override
  String get toastChargeComplete =>
      'Carga completa. Cuelga la manguera para pagar.';

  @override
  String get toastGnvPreferred =>
      'El auto usará GNV y cambiará a gasolina si se acaba.';

  @override
  String get toastGasolineOnly => 'El auto usará solo gasolina.';

  @override
  String toastStationShared(String station) {
    return 'Ubicación de $station copiada.';
  }

  @override
  String get toastFavoriteAdded => 'Grifo guardado en favoritos.';

  @override
  String get toastFavoriteRemoved => 'Quitado de favoritos.';

  @override
  String get toastFiltersInfo => 'Filtros: abierto ahora · pago en app';

  @override
  String get toastSettingsUnavailable => 'Ajustes todavía no está disponible.';

  @override
  String get toastInvalidDni => 'El DNI debe tener 8 dígitos.';

  @override
  String get toastInvalidRuc =>
      'El RUC debe tener 11 dígitos y empezar con 10 o 20.';

  @override
  String get toastReceiptShared =>
      'Comprobante listo para compartir (PDF y XML).';

  @override
  String toastPaidByEmail(String amount, String document) {
    return 'Pagaste $amount. Te enviamos la $document por correo.';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get done => 'Listo';

  @override
  String get yes => 'Sí';

  @override
  String get soles => 'S/';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsReadAll => 'Leer todo';

  @override
  String get notificationsEmpty => 'No tienes avisos nuevos.';

  @override
  String get notifCertTitle => 'Certificación por vencer';

  @override
  String notifCertBody(String date) {
    return 'Tu certificación anual de GNV vence el $date. Agenda tu renovación.';
  }

  @override
  String get notifPriceTitle => 'Bajó el precio del GNV';

  @override
  String notifPriceBody(String price, String station) {
    return 'GNV a $price en $station. Es el más barato cerca de ti.';
  }

  @override
  String get notifPaymentTitle => 'Pago registrado';

  @override
  String notifPaymentBody(String amount, String station, String document) {
    return 'Pagaste $amount en $station. Tu $document ya está disponible.';
  }

  @override
  String notifPointsTitle(int points) {
    return 'Ganaste $points puntos';
  }

  @override
  String notifPointsBody(String balance) {
    return 'Por tu última carga. Ya tienes $balance puntos Tankeo.';
  }

  @override
  String get notifApptTitle => 'Cita confirmada';

  @override
  String notifApptBody(String shop, String day, String time) {
    return 'Renovación en $shop, $day a las $time.';
  }

  @override
  String get timeNow => 'ahora';

  @override
  String timeMinutesAgo(int n) {
    return 'hace $n min';
  }

  @override
  String timeHoursAgo(int n) {
    return 'hace $n h';
  }

  @override
  String timeDaysAgo(int n) {
    return 'hace $n d';
  }

  @override
  String get historyTitle => 'Historial de cargas';

  @override
  String historyMonthTotal(String month) {
    return 'Gastado en $month';
  }

  @override
  String historyChargesCount(int n) {
    return '$n cargas';
  }

  @override
  String historyGnvShare(int pct) {
    return '$pct % con GNV';
  }

  @override
  String get filterInvoices => 'Facturas';

  @override
  String get historyNew => 'Nuevo';

  @override
  String get historyEmpty => 'No hay cargas con este filtro.';

  @override
  String historyDocLine(String document, String volume, String unit) {
    return '$document · $volume $unit';
  }

  @override
  String get certScreenTitle => 'Certificación GNV';

  @override
  String get certStatusValid => 'Vigente';

  @override
  String get certStatusExpired => 'Vencida';

  @override
  String certDaysLeft(int n) {
    return '$n días restantes';
  }

  @override
  String certExpiredDaysAgo(int n) {
    return 'Venció hace $n días';
  }

  @override
  String get certDataTitle => 'Datos del cilindro';

  @override
  String get certChip => 'Chip Infogas';

  @override
  String get certCylinderLabel => 'Cilindro';

  @override
  String get certShop => 'Taller';

  @override
  String get certValidUntil => 'Vigente hasta';

  @override
  String get certNextReview => 'Próxima revisión';

  @override
  String get certTimeline => 'Historial de inspecciones';

  @override
  String get certInspectionAnnual => 'Inspección anual';

  @override
  String get certInspectionConversion => 'Conversión e instalación';

  @override
  String get certApproved => 'Aprobada';

  @override
  String get certSchedule => 'Agendar renovación';

  @override
  String get certScheduled => 'Cita agendada';

  @override
  String certScheduledBody(String shop, String day, String time) {
    return '$shop · $day, $time';
  }

  @override
  String get certScheduleTitle => 'Agendar renovación';

  @override
  String get certScheduleShop => 'Taller';

  @override
  String get certScheduleDay => 'Día';

  @override
  String get certScheduleTime => 'Hora';

  @override
  String get certScheduleConfirm => 'Confirmar cita';

  @override
  String get shopSurco => 'GNV Autorizado Surco';

  @override
  String get shopMiraflores => 'Taller Infogas Miraflores';

  @override
  String get shopLince => 'Centro GNV Lince';

  @override
  String get weekdayShort => 'dom,lun,mar,mié,jue,vie,sáb';

  @override
  String toastApptConfirmed(String shop) {
    return 'Cita confirmada en $shop.';
  }

  @override
  String get pointsTitle => 'Puntos Tankeo';

  @override
  String get pointsBalance => 'Tu saldo';

  @override
  String get pointsUnit => 'puntos';

  @override
  String get pointsTierSilver => 'Nivel Plata';

  @override
  String get pointsTierGold => 'Nivel Oro';

  @override
  String pointsToGold(String n) {
    return '$n puntos para Oro';
  }

  @override
  String get pointsRule => 'Ganas 1 punto por cada S/ 1 cargado.';

  @override
  String get pointsRedeem => 'Canjea';

  @override
  String get pointsMovements => 'Movimientos';

  @override
  String pointsMissing(String n) {
    return 'Faltan $n';
  }

  @override
  String get pointsRewardGnv => 'S/ 5 en GNV';

  @override
  String get pointsRewardCoffee => 'Café en tienda';

  @override
  String get pointsRewardWash => 'Lavado de auto';

  @override
  String get pointsRewardGasoline => 'S/ 20 en gasolina';

  @override
  String pointsCost(String n) {
    return '$n pts';
  }

  @override
  String redeemTitle(String reward) {
    return '¿Canjear $reward?';
  }

  @override
  String redeemBody(String cost, String left) {
    return 'Se descontarán $cost puntos. Te quedarán $left.';
  }

  @override
  String get redeemConfirm => 'Canjear';

  @override
  String toastRedeemed(String code) {
    return 'Canje listo. Tu código es $code.';
  }

  @override
  String movementCharge(String station) {
    return 'Carga en $station';
  }

  @override
  String get movementWelcome => 'Regalo de bienvenida';

  @override
  String movementRedeem(String reward) {
    return 'Canje: $reward';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccount => 'Mi cuenta';

  @override
  String get settingsPrefs => 'Preferencias';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsVehicles => 'Mis vehículos';

  @override
  String get settingsPayments => 'Métodos de pago';

  @override
  String get settingsBilling => 'Datos de facturación';

  @override
  String get settingsHistory => 'Historial de cargas';

  @override
  String get settingsCert => 'Certificación GNV';

  @override
  String get settingsPoints => 'Puntos Tankeo';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPriceAlerts => 'Avisos de bajada de precio';

  @override
  String get settingsCertReminder => 'Recordatorio de certificación';

  @override
  String get settingsPreferredFuel => 'Combustible preferido';

  @override
  String get settingsHelp => 'Ayuda y contacto';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsVersion => 'Tankeo 1.0';

  @override
  String get settingsCredits =>
      'Modelo 3D «McLaren F1 1993» de Alex.Ka. (Sketchfab) · CC BY-NC 4.0';

  @override
  String profilePoints(String n) {
    return '$n pts';
  }

  @override
  String get profilePhone => '+51 987 654 321';

  @override
  String get logoutTitle => '¿Cerrar sesión?';

  @override
  String get logoutBody =>
      'Tendrás que volver a ingresar para cargar desde tu auto.';

  @override
  String get logoutConfirm => 'Cerrar sesión';

  @override
  String get toastHelp =>
      'Escríbenos a ayuda@tankeo.pe y te respondemos en minutos.';

  @override
  String get vehiclesTitle => 'Mis vehículos';

  @override
  String get vehicleInUse => 'En uso';

  @override
  String get vehicleAdd => 'Agregar vehículo';

  @override
  String vehicleTankGas(int pct) {
    return 'Tanque $pct %';
  }

  @override
  String vehicleTankGnv(int pct) {
    return 'Cilindro $pct %';
  }

  @override
  String get vehicleCertOk => 'Certificación vigente';

  @override
  String get vehicleCertNone => 'Sin GNV';

  @override
  String get vehicleFuelDual => 'Dual gasolina + GNV';

  @override
  String get vehicleFuelGasoline => 'Solo gasolina';

  @override
  String get vehicleFuelGnv => 'Solo GNV';

  @override
  String get vehicleFuelDualShort => 'Dual';

  @override
  String get vehicleUse => 'Usar';

  @override
  String get paymentsTitle => 'Métodos de pago';

  @override
  String get paymentDefault => 'Predeterminado';

  @override
  String get paymentUse => 'Usar';

  @override
  String get paymentRemove => 'Quitar';

  @override
  String get paymentAddCard => 'Agregar tarjeta';

  @override
  String get paymentSecurityNote =>
      'Tus tarjetas se guardan cifradas: solo conservamos un token y los últimos 4 dígitos.';

  @override
  String get paymentYapeLabel => 'Yape';

  @override
  String get paymentPlinLabel => 'Plin';

  @override
  String paymentCardDetail(String date) {
    return 'Vence $date';
  }

  @override
  String paymentPhoneDetail(String last) {
    return 'Celular •••• $last';
  }

  @override
  String toastPaymentDefault(String method) {
    return '$method es tu método predeterminado.';
  }

  @override
  String get toastPaymentRemoved => 'Método quitado.';

  @override
  String get toastPaymentLast => 'Debes conservar al menos un método de pago.';

  @override
  String get toastCardAdded => 'Tarjeta agregada.';

  @override
  String get cardTitle => 'Agregar tarjeta';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get cardExpiry => 'MM/AA';

  @override
  String get cardCvv => 'CVV';

  @override
  String get cardHolder => 'Titular de la tarjeta';

  @override
  String get cardHolderPreview => 'TITULAR';

  @override
  String get cardSave => 'Guardar tarjeta';

  @override
  String get errCardNumber => 'Número de tarjeta no válido.';

  @override
  String get errCardExpiry => 'Fecha vencida o no válida.';

  @override
  String get errCardCvv => 'CVV de 3 o 4 dígitos.';

  @override
  String get errCardHolder => 'Escribe nombre y apellido.';

  @override
  String get cardBrandVisa => 'Visa';

  @override
  String get cardBrandMastercard => 'Mastercard';

  @override
  String get cardBrandAmex => 'Amex';

  @override
  String get cardBrandCard => 'Tarjeta';

  @override
  String get billingTitle => 'Datos de facturación';

  @override
  String get billingBoleta => 'Para boletas';

  @override
  String get billingFactura => 'Para facturas';

  @override
  String get billingNote =>
      'Se usarán para rellenar el comprobante en el resumen de carga.';

  @override
  String get toastBillingSaved => 'Datos de facturación guardados.';

  @override
  String get signupTitle => 'Crea tu cuenta';

  @override
  String get signupStepAccount => 'Tu cuenta';

  @override
  String get signupStepVehicle => 'Tu vehículo';

  @override
  String get signupStepGnv => 'Tu cilindro GNV';

  @override
  String signupStepCounter(int step, int total) {
    return '$step/$total';
  }

  @override
  String get signupName => 'Nombre completo';

  @override
  String get signupEmail => 'Correo electrónico';

  @override
  String get signupPhone => 'Celular';

  @override
  String get signupPassword => 'Contraseña';

  @override
  String get signupTerms => 'Acepto los términos y la política de privacidad';

  @override
  String get errName => 'Escribe nombre y apellido.';

  @override
  String get errEmail => 'Correo no válido.';

  @override
  String get errPhone => 'Celular de 9 dígitos que empieza con 9.';

  @override
  String get errPassword => 'Usa 8 caracteres, mayúscula y número.';

  @override
  String get errTerms => 'Debes aceptar los términos.';

  @override
  String get strengthWeak => 'Débil';

  @override
  String get strengthMedium => 'Media';

  @override
  String get strengthStrong => 'Fuerte';

  @override
  String get vehicleName => 'Marca y modelo';

  @override
  String get vehiclePlate => 'Placa';

  @override
  String get vehicleYear => 'Año';

  @override
  String get vehicleFuelType => 'Combustible';

  @override
  String get vehicleTankCapacity => 'Capacidad del tanque (gal)';

  @override
  String get vehicleCylinderCapacity => 'Capacidad del cilindro (m³)';

  @override
  String get errVehicleName => 'Escribe la marca y el modelo.';

  @override
  String get errPlate => 'Placa con formato ABC-123.';

  @override
  String get errYear => 'Año no válido.';

  @override
  String get gnvChip => 'Chip Infogas';

  @override
  String get gnvChipHint => '0000-0000-00';

  @override
  String get gnvExpiry => 'Vence la certificación';

  @override
  String get gnvExpiryHint => 'dd/mm/aaaa';

  @override
  String get gnvCylinderType => 'Tipo de cilindro';

  @override
  String get gnvCylinderNote =>
      'Los GNV-1 se revisan cada 5 años; los GNV-2 y GNV-4, cada 4.';

  @override
  String get errChip => 'Chip con formato 0000-0000-00.';

  @override
  String get errExpiry => 'Fecha no válida.';

  @override
  String get signupNext => 'Continuar';

  @override
  String get signupStart => 'Empezar a usar Tankeo';

  @override
  String get signupAddFinish => 'Guardar vehículo';

  @override
  String signupDoneTitle(String name) {
    return '¡Listo, $name!';
  }

  @override
  String get signupDoneBody =>
      'Tu cuenta está creada. Empieza a cargar sin bajarte del auto.';

  @override
  String signupGift(int n) {
    return '+$n puntos de bienvenida';
  }

  @override
  String get addVehicleTitle => 'Agregar vehículo';

  @override
  String get resetTitle => 'Recupera tu contraseña';

  @override
  String get resetEmailBody =>
      'Escribe tu correo y te enviamos un código de 4 dígitos.';

  @override
  String get resetSend => 'Enviar código';

  @override
  String get resetCodeTitle => 'Revisa tu correo';

  @override
  String resetCodeBody(String email) {
    return 'Ingresa el código que enviamos a $email.';
  }

  @override
  String get resetVerify => 'Verificar código';

  @override
  String get resetResend => 'Reenviar código';

  @override
  String resetResendIn(int n) {
    return 'Reenviar en $n s';
  }

  @override
  String resetWrongCode(int n) {
    return 'Código incorrecto. Te quedan $n intentos.';
  }

  @override
  String get resetNoAttempts => 'Sin intentos. Pide un código nuevo.';

  @override
  String get resetNewTitle => 'Crea una contraseña nueva';

  @override
  String get resetNewBody => 'Usa una que no hayas usado antes.';

  @override
  String get resetNewPassword => 'Contraseña nueva';

  @override
  String get resetRepeatPassword => 'Repite la contraseña';

  @override
  String get resetMismatch => 'Las contraseñas no coinciden.';

  @override
  String get resetUpdate => 'Actualizar contraseña';

  @override
  String get toastPasswordUpdated => 'Contraseña actualizada.';

  @override
  String get toastCodeSent => 'Te enviamos un código nuevo.';

  @override
  String get navTabCar => 'Auto';

  @override
  String get navTabFuel => 'Carga';

  @override
  String get navTabStations => 'Grifos';

  @override
  String get navTabSettings => 'Ajustes';

  @override
  String get navFuelInProgress => 'Carga en curso';

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get navOverview => 'Vista general';

  @override
  String navTurnRight(String street) {
    return 'Gira a la derecha en $street';
  }

  @override
  String navTurnLeft(String street) {
    return 'Gira a la izquierda en $street';
  }

  @override
  String navStraight(String street) {
    return 'Sigue recto por $street';
  }

  @override
  String navDestination(String station) {
    return 'Tu destino: $station';
  }

  @override
  String get navThen => 'Luego';

  @override
  String navInDistance(String distance) {
    return 'En $distance';
  }

  @override
  String navMeters(int n) {
    return '$n m';
  }

  @override
  String navKm(String n) {
    return '$n km';
  }

  @override
  String navArrivedBanner(String isle, String pump) {
    return 'Llegaste · Entra a la isla $isle · surtidor $pump';
  }

  @override
  String get navArrivedTitle => 'Llegaste';

  @override
  String navRemaining(String distance, int minutes) {
    return '$distance en $minutes min';
  }

  @override
  String navArrival(String time) {
    return 'llegada $time';
  }

  @override
  String get navContinue => 'Continuar a la carga';

  @override
  String get navSlideContinue => 'Desliza para ir a la carga';

  @override
  String get navOverviewTag => 'Vista general de la ruta';

  @override
  String get navDistanceThen => 'luego gira';

  @override
  String get navTurnNow => 'Gira ahora';

  @override
  String navTurnLeftOn(String street) {
    return 'A la izquierda en $street';
  }

  @override
  String navTurnRightOn(String street) {
    return 'A la derecha en $street';
  }

  @override
  String get navLeftPlain => 'Gira a la izquierda';

  @override
  String get navRightPlain => 'Gira a la derecha';

  @override
  String get navStraightPlain => 'Sigue recto';

  @override
  String get navNextLeftPlain => 'Luego a la izquierda';

  @override
  String get navNextRightPlain => 'Luego a la derecha';

  @override
  String get navNextStraightPlain => 'Luego sigue recto';

  @override
  String get navNextLeft => 'Luego a la izquierda en';

  @override
  String get navNextRight => 'Luego a la derecha en';

  @override
  String get navNextStraight => 'Luego sigue recto por';

  @override
  String get navNextDestination => 'Luego llegas a';

  @override
  String navEtaLine(String distance, String time) {
    return '$distance · llegada $time';
  }

  @override
  String get navExitTitle => '¿Salir de la navegación?';

  @override
  String get navExitBody => 'Dejarás de recibir indicaciones hacia el grifo.';

  @override
  String get navExitKeep => 'Seguir';

  @override
  String get navExitConfirm => 'Salir';

  @override
  String navSpeedLimit(int n) {
    return 'Límite $n km/h';
  }

  @override
  String get navDestinationOpen => 'Ver detalle del grifo';

  @override
  String get arrivalBannerEyebrow => 'Llegaste a tu grifo';

  @override
  String arrivalBannerTitle(String island) {
    return 'Entra a la isla $island';
  }

  @override
  String arrivalBannerSubtitle(String pump, String side) {
    return 'Surtidor $pump · a tu $side';
  }

  @override
  String get arrivalSideRight => 'derecha';

  @override
  String get arrivalSideLeft => 'izquierda';

  @override
  String get arrivalChip => 'Llegaste';

  @override
  String get arrivalStatDistance => 'Recorrido';

  @override
  String get arrivalStatTime => 'Tiempo';

  @override
  String get arrivalStatArrival => 'Llegada';

  @override
  String get arrivalPumpShort => 'SURT.';

  @override
  String arrivalPumpTitle(String island, String fuels) {
    return 'Isla $island · $fuels';
  }

  @override
  String get arrivalFuelsBoth => 'GNV y gasolina';

  @override
  String get arrivalPumpFree => 'Libre ahora';

  @override
  String get arrivalPumpBusy => 'Ocupado · te toca pronto';

  @override
  String get arrivalSlide => 'Desliza para empezar la carga';

  @override
  String get arrivalExit => 'Salir de la navegación';

  @override
  String navPumpChip(String pump) {
    return 'Surtidor $pump';
  }

  @override
  String navIsleChip(String isle) {
    return 'Isla $isle';
  }

  @override
  String navDistanceChip(String distance, int minutes) {
    return '$distance · $minutes min';
  }

  @override
  String get navExit => 'Salir';

  @override
  String get navView2d => '2D';

  @override
  String get navView3d => '3D';

  @override
  String get navRecenter => 'Recentrar';

  @override
  String get navSpeedUnit => 'km/h';

  @override
  String get toastNear3d => 'Estás cerca: vista 3D activada.';

  @override
  String get streetCanaval => 'Av. Canaval y Moreyra';

  @override
  String get streetJavierPrado => 'Av. Javier Prado';

  @override
  String get streetPetitThouars => 'Av. Petit Thouars';

  @override
  String get streetArequipa => 'Av. Arequipa';

  @override
  String get streetAmericaSur => 'Calle Los Cedros';
}
