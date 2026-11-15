import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'TANKEO'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In es, this message translates to:
  /// **'CARGA RÁPIDO  ·  PAGA DESDE TU AUTO'**
  String get splashTagline;

  /// No description provided for @carSemantic.
  ///
  /// In es, this message translates to:
  /// **'McLaren F1'**
  String get carSemantic;

  /// No description provided for @carSemanticYear.
  ///
  /// In es, this message translates to:
  /// **'McLaren F1 1993'**
  String get carSemanticYear;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Hola de nuevo! Ingresa para cargar sin bajarte del auto.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordHint;

  /// No description provided for @loginShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get loginHidePassword;

  /// No description provided for @loginForgot.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgot;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get loginSubmit;

  /// No description provided for @loginOr.
  ///
  /// In es, this message translates to:
  /// **'O ingresa con'**
  String get loginOr;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get loginNoAccount;

  /// No description provided for @loginRegister.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegister;

  /// No description provided for @navCar.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get navCar;

  /// No description provided for @navCharge.
  ///
  /// In es, this message translates to:
  /// **'Carga'**
  String get navCharge;

  /// No description provided for @navStations.
  ///
  /// In es, this message translates to:
  /// **'Grifos'**
  String get navStations;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @greetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días,\n{name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes,\n{name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches,\n{name}'**
  String greetingEvening(String name);

  /// No description provided for @homeCarSubtitle.
  ///
  /// In es, this message translates to:
  /// **'McLaren F1 1993 · Dual gasolina + GNV'**
  String get homeCarSubtitle;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @homeFuelTitle.
  ///
  /// In es, this message translates to:
  /// **'Combustible'**
  String get homeFuelTitle;

  /// No description provided for @homeLastCharge.
  ///
  /// In es, this message translates to:
  /// **'Última carga hace 2 días'**
  String get homeLastCharge;

  /// No description provided for @homeVolumeOf.
  ///
  /// In es, this message translates to:
  /// **'{current} de {capacity} {unit}'**
  String homeVolumeOf(String current, String capacity, String unit);

  /// No description provided for @fuelGasoline.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get fuelGasoline;

  /// No description provided for @fuelGnv.
  ///
  /// In es, this message translates to:
  /// **'GNV'**
  String get fuelGnv;

  /// No description provided for @homeTotalRange.
  ///
  /// In es, this message translates to:
  /// **'Autonomía total'**
  String get homeTotalRange;

  /// No description provided for @kmValue.
  ///
  /// In es, this message translates to:
  /// **'{count} km'**
  String kmValue(int count);

  /// No description provided for @odometerValue.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String odometerValue(String km);

  /// No description provided for @homeOdometer.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get homeOdometer;

  /// No description provided for @homeCheapestGnv.
  ///
  /// In es, this message translates to:
  /// **'GNV más barato cerca'**
  String get homeCheapestGnv;

  /// No description provided for @homeFindCheapest.
  ///
  /// In es, this message translates to:
  /// **'Encuentra el grifo más barato'**
  String get homeFindCheapest;

  /// No description provided for @homeSeeStations.
  ///
  /// In es, this message translates to:
  /// **'Ver grifos'**
  String get homeSeeStations;

  /// No description provided for @etaMinKm.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min · {km} km'**
  String etaMinKm(int minutes, String km);

  /// No description provided for @homeQuickControls.
  ///
  /// In es, this message translates to:
  /// **'Controles rápidos'**
  String get homeQuickControls;

  /// No description provided for @homeEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get homeEdit;

  /// No description provided for @controlDoors.
  ///
  /// In es, this message translates to:
  /// **'Puertas'**
  String get controlDoors;

  /// No description provided for @controlDoorsOn.
  ///
  /// In es, this message translates to:
  /// **'Cerradas'**
  String get controlDoorsOn;

  /// No description provided for @controlDoorsOff.
  ///
  /// In es, this message translates to:
  /// **'Abiertas'**
  String get controlDoorsOff;

  /// No description provided for @controlGnvOn.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get controlGnvOn;

  /// No description provided for @controlGnvOff.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get controlGnvOff;

  /// No description provided for @controlLights.
  ///
  /// In es, this message translates to:
  /// **'Luces'**
  String get controlLights;

  /// No description provided for @controlLightsOn.
  ///
  /// In es, this message translates to:
  /// **'Encendidas'**
  String get controlLightsOn;

  /// No description provided for @controlLightsOff.
  ///
  /// In es, this message translates to:
  /// **'Apagadas'**
  String get controlLightsOff;

  /// No description provided for @controlCap.
  ///
  /// In es, this message translates to:
  /// **'Tapa'**
  String get controlCap;

  /// No description provided for @controlCapOn.
  ///
  /// In es, this message translates to:
  /// **'Abierta'**
  String get controlCapOn;

  /// No description provided for @controlCapOff.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get controlCapOff;

  /// No description provided for @certTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificación GNV'**
  String get certTitle;

  /// No description provided for @certSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Chip Infogas activo · Cilindro {cylinder}'**
  String certSubtitle(String cylinder);

  /// No description provided for @certValid.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get certValid;

  /// No description provided for @certAnnualExpires.
  ///
  /// In es, this message translates to:
  /// **'Anual vence'**
  String get certAnnualExpires;

  /// No description provided for @certDays.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get certDays;

  /// No description provided for @certReview.
  ///
  /// In es, this message translates to:
  /// **'Revisión del cilindro (cada 4 años): {date}'**
  String certReview(String date);

  /// No description provided for @spendTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto esta semana'**
  String get spendTitle;

  /// No description provided for @spendSaved.
  ///
  /// In es, this message translates to:
  /// **'Ahorraste {amount}'**
  String spendSaved(String amount);

  /// No description provided for @spendWithGnv.
  ///
  /// In es, this message translates to:
  /// **'usando GNV'**
  String get spendWithGnv;

  /// No description provided for @weekdayInitials.
  ///
  /// In es, this message translates to:
  /// **'D,L,M,M,J,V,S'**
  String get weekdayInitials;

  /// No description provided for @tiresTitle.
  ///
  /// In es, this message translates to:
  /// **'Presión de llantas'**
  String get tiresTitle;

  /// No description provided for @tiresLowFrontLeft.
  ///
  /// In es, this message translates to:
  /// **'Delantera izq. baja'**
  String get tiresLowFrontLeft;

  /// No description provided for @tiresCarSemantic.
  ///
  /// In es, this message translates to:
  /// **'Auto visto desde arriba'**
  String get tiresCarSemantic;

  /// No description provided for @psi.
  ///
  /// In es, this message translates to:
  /// **'psi'**
  String get psi;

  /// No description provided for @tireLowTemp.
  ///
  /// In es, this message translates to:
  /// **'Baja · {temp}°C'**
  String tireLowTemp(int temp);

  /// No description provided for @tireTemp.
  ///
  /// In es, this message translates to:
  /// **'{temp}°C'**
  String tireTemp(int temp);

  /// No description provided for @gnvSavingsValue.
  ///
  /// In es, this message translates to:
  /// **'52%'**
  String get gnvSavingsValue;

  /// No description provided for @gnvSavingsLabel.
  ///
  /// In es, this message translates to:
  /// **'Ahorro con GNV'**
  String get gnvSavingsLabel;

  /// No description provided for @gnvEfficiencyValue.
  ///
  /// In es, this message translates to:
  /// **'13 km/m³'**
  String get gnvEfficiencyValue;

  /// No description provided for @gnvEfficiencyLabel.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento GNV'**
  String get gnvEfficiencyLabel;

  /// No description provided for @fuelRegular.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get fuelRegular;

  /// No description provided for @fuelPremium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get fuelPremium;

  /// No description provided for @fuelDiesel.
  ///
  /// In es, this message translates to:
  /// **'Diésel B5'**
  String get fuelDiesel;

  /// No description provided for @fuelRegularLong.
  ///
  /// In es, this message translates to:
  /// **'Gasohol Regular'**
  String get fuelRegularLong;

  /// No description provided for @fuelPremiumLong.
  ///
  /// In es, this message translates to:
  /// **'Gasohol Premium'**
  String get fuelPremiumLong;

  /// No description provided for @mapTitle.
  ///
  /// In es, this message translates to:
  /// **'Grifos cercanos'**
  String get mapTitle;

  /// No description provided for @filters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @zoomIn.
  ///
  /// In es, this message translates to:
  /// **'Acercar'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In es, this message translates to:
  /// **'Alejar'**
  String get zoomOut;

  /// No description provided for @centerOnCar.
  ///
  /// In es, this message translates to:
  /// **'Centrar en mi auto'**
  String get centerOnCar;

  /// No description provided for @mapLocation.
  ///
  /// In es, this message translates to:
  /// **'San Isidro, Lima'**
  String get mapLocation;

  /// No description provided for @cheapestTag.
  ///
  /// In es, this message translates to:
  /// **'Más barato'**
  String get cheapestTag;

  /// No description provided for @pumpsAllBusy.
  ///
  /// In es, this message translates to:
  /// **'Todos ocupados'**
  String get pumpsAllBusy;

  /// No description provided for @pumpsFree.
  ///
  /// In es, this message translates to:
  /// **'{free}/{total} libres'**
  String pumpsFree(int free, int total);

  /// No description provided for @pumpsFreeShort.
  ///
  /// In es, this message translates to:
  /// **'{free}/{total} libres'**
  String pumpsFreeShort(int free, int total);

  /// No description provided for @ratingLine.
  ///
  /// In es, this message translates to:
  /// **'{rating} · {minutes} min · {km} km'**
  String ratingLine(String rating, int minutes, String km);

  /// No description provided for @addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get addressLabel;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @viewDetail.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get viewDetail;

  /// No description provided for @detailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get detailTitle;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @moreOptions.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get moreOptions;

  /// No description provided for @detailSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get detailSummary;

  /// No description provided for @open24h.
  ///
  /// In es, this message translates to:
  /// **'Abierto 24 h'**
  String get open24h;

  /// No description provided for @open24hLong.
  ///
  /// In es, this message translates to:
  /// **'Abierto 24 horas'**
  String get open24hLong;

  /// No description provided for @detailPumps.
  ///
  /// In es, this message translates to:
  /// **'Surtidores'**
  String get detailPumps;

  /// No description provided for @detailGnvChip.
  ///
  /// In es, this message translates to:
  /// **'Chip GNV'**
  String get detailGnvChip;

  /// No description provided for @detailInfogasOnline.
  ///
  /// In es, this message translates to:
  /// **'Infogas en línea'**
  String get detailInfogasOnline;

  /// No description provided for @detailPayInApp.
  ///
  /// In es, this message translates to:
  /// **'Pago en app'**
  String get detailPayInApp;

  /// No description provided for @detailPayMethods.
  ///
  /// In es, this message translates to:
  /// **'Yape · Plin · Tarjeta'**
  String get detailPayMethods;

  /// No description provided for @detailTodayPrices.
  ///
  /// In es, this message translates to:
  /// **'Precios de hoy'**
  String get detailTodayPrices;

  /// No description provided for @pricesIncludeIgv.
  ///
  /// In es, this message translates to:
  /// **'Precios incluyen IGV. Compáralos también en Facilito de Osinergmin.'**
  String get pricesIncludeIgv;

  /// No description provided for @detailPumpsTitle.
  ///
  /// In es, this message translates to:
  /// **'Surtidores'**
  String get detailPumpsTitle;

  /// No description provided for @detailServices.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get detailServices;

  /// No description provided for @amenityStore.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get amenityStore;

  /// No description provided for @amenityRestrooms.
  ///
  /// In es, this message translates to:
  /// **'Baños'**
  String get amenityRestrooms;

  /// No description provided for @amenityAir.
  ///
  /// In es, this message translates to:
  /// **'Aire'**
  String get amenityAir;

  /// No description provided for @amenityWash.
  ///
  /// In es, this message translates to:
  /// **'Lavado'**
  String get amenityWash;

  /// No description provided for @amenityAtm.
  ///
  /// In es, this message translates to:
  /// **'Cajero'**
  String get amenityAtm;

  /// No description provided for @amenitySecurity.
  ///
  /// In es, this message translates to:
  /// **'Vigilancia 24/7'**
  String get amenitySecurity;

  /// No description provided for @detailReviews.
  ///
  /// In es, this message translates to:
  /// **'Reseñas'**
  String get detailReviews;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get seeAll;

  /// No description provided for @reviewCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reseñas'**
  String reviewCount(int count);

  /// No description provided for @reviewer1Name.
  ///
  /// In es, this message translates to:
  /// **'Lucía Quispe'**
  String get reviewer1Name;

  /// No description provided for @reviewer1When.
  ///
  /// In es, this message translates to:
  /// **'hace 2 días'**
  String get reviewer1When;

  /// No description provided for @reviewer1Text.
  ///
  /// In es, this message translates to:
  /// **'Cargo GNV aquí todos los días con el taxi. Rápido, leen el chip al toque y pago con Yape desde el auto.'**
  String get reviewer1Text;

  /// No description provided for @reviewer2Name.
  ///
  /// In es, this message translates to:
  /// **'Jorge Ramírez'**
  String get reviewer2Name;

  /// No description provided for @reviewer2When.
  ///
  /// In es, this message translates to:
  /// **'hace 1 semana'**
  String get reviewer2When;

  /// No description provided for @reviewer2Text.
  ///
  /// In es, this message translates to:
  /// **'Buen precio en Regular. En hora punta (7 a 9 am) se forma cola en las islas de GNV.'**
  String get reviewer2Text;

  /// No description provided for @detailDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get detailDistance;

  /// No description provided for @detailByCar.
  ///
  /// In es, this message translates to:
  /// **'En auto'**
  String get detailByCar;

  /// No description provided for @minutesValue.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// No description provided for @detailFillEstimate.
  ///
  /// In es, this message translates to:
  /// **'≈ {amount} para llenar {fuel}'**
  String detailFillEstimate(String amount, String fuel);

  /// No description provided for @goToCharge.
  ///
  /// In es, this message translates to:
  /// **'Ir a cargar'**
  String get goToCharge;

  /// No description provided for @pumpFree.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get pumpFree;

  /// No description provided for @pumpBusy.
  ///
  /// In es, this message translates to:
  /// **'Ocupado'**
  String get pumpBusy;

  /// No description provided for @pumpFuelsGnv.
  ///
  /// In es, this message translates to:
  /// **'GNV · R · P'**
  String get pumpFuelsGnv;

  /// No description provided for @pumpFuelsLiquid.
  ///
  /// In es, this message translates to:
  /// **'R · P · D'**
  String get pumpFuelsLiquid;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @pumpLabel.
  ///
  /// In es, this message translates to:
  /// **'Surtidor {pump}'**
  String pumpLabel(String pump);

  /// No description provided for @tankGnvTitle.
  ///
  /// In es, this message translates to:
  /// **'Cilindro GNV'**
  String get tankGnvTitle;

  /// No description provided for @tankGasolineTitle.
  ///
  /// In es, this message translates to:
  /// **'Tanque de gasolina'**
  String get tankGasolineTitle;

  /// No description provided for @chipInfogas.
  ///
  /// In es, this message translates to:
  /// **'Chip Infogas'**
  String get chipInfogas;

  /// No description provided for @chipValidated.
  ///
  /// In es, this message translates to:
  /// **'Chip validado'**
  String get chipValidated;

  /// No description provided for @levelVolume.
  ///
  /// In es, this message translates to:
  /// **'Nivel · {volume} {unit}'**
  String levelVolume(String volume, String unit);

  /// No description provided for @rangeGnv.
  ///
  /// In es, this message translates to:
  /// **'Autonomía GNV'**
  String get rangeGnv;

  /// No description provided for @rangeGasoline.
  ///
  /// In es, this message translates to:
  /// **'Autonomía gasolina'**
  String get rangeGasoline;

  /// No description provided for @chargeHowMuch.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto cargar?'**
  String get chargeHowMuch;

  /// No description provided for @chargeFull.
  ///
  /// In es, this message translates to:
  /// **'Lleno'**
  String get chargeFull;

  /// No description provided for @chargeFits.
  ///
  /// In es, this message translates to:
  /// **'Caben {volume} {unit}'**
  String chargeFits(String volume, String unit);

  /// No description provided for @chargeAuthorize.
  ///
  /// In es, this message translates to:
  /// **'Autorizar surtidor {pump}'**
  String chargeAuthorize(String pump);

  /// No description provided for @chargeValidatingChip.
  ///
  /// In es, this message translates to:
  /// **'Validando chip Infogas…'**
  String get chargeValidatingChip;

  /// No description provided for @chargeConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando con el surtidor…'**
  String get chargeConnecting;

  /// No description provided for @chargeViewPump.
  ///
  /// In es, this message translates to:
  /// **'Ver surtidor'**
  String get chargeViewPump;

  /// No description provided for @chargePay.
  ///
  /// In es, this message translates to:
  /// **'Pagar {amount}'**
  String chargePay(String amount);

  /// No description provided for @sheetDispensing.
  ///
  /// In es, this message translates to:
  /// **'Despachando'**
  String get sheetDispensing;

  /// No description provided for @sheetComplete.
  ///
  /// In es, this message translates to:
  /// **'Carga completa'**
  String get sheetComplete;

  /// No description provided for @sheetHungUp.
  ///
  /// In es, this message translates to:
  /// **'Manguera colgada'**
  String get sheetHungUp;

  /// No description provided for @sheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{station} · Surtidor {pump}'**
  String sheetSubtitle(String station, String pump);

  /// No description provided for @minimize.
  ///
  /// In es, this message translates to:
  /// **'Minimizar'**
  String get minimize;

  /// No description provided for @lcdProductGnv.
  ///
  /// In es, this message translates to:
  /// **'GNV · MANGUERA 2'**
  String get lcdProductGnv;

  /// No description provided for @lcdProductGasoline.
  ///
  /// In es, this message translates to:
  /// **'{product} · MANGUERA 1'**
  String lcdProductGasoline(String product);

  /// No description provided for @lcdStatusRunning.
  ///
  /// In es, this message translates to:
  /// **'EN CURSO'**
  String get lcdStatusRunning;

  /// No description provided for @lcdStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'COMPLETADO'**
  String get lcdStatusCompleted;

  /// No description provided for @lcdStatusHungUp.
  ///
  /// In es, this message translates to:
  /// **'COLGADA'**
  String get lcdStatusHungUp;

  /// No description provided for @lcdStatusReady.
  ///
  /// In es, this message translates to:
  /// **'LISTO'**
  String get lcdStatusReady;

  /// No description provided for @lcdAmount.
  ///
  /// In es, this message translates to:
  /// **'IMPORTE S/'**
  String get lcdAmount;

  /// No description provided for @lcdVolume.
  ///
  /// In es, this message translates to:
  /// **'VOLUMEN {unit}'**
  String lcdVolume(String unit);

  /// No description provided for @lcdPrice.
  ///
  /// In es, this message translates to:
  /// **'PRECIO S/ / {unit}'**
  String lcdPrice(String unit);

  /// No description provided for @levelWord.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get levelWord;

  /// No description provided for @rangeWord.
  ///
  /// In es, this message translates to:
  /// **'Autonomía'**
  String get rangeWord;

  /// No description provided for @timeWord.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get timeWord;

  /// No description provided for @progressRemaining.
  ///
  /// In es, this message translates to:
  /// **'Faltan {amount}'**
  String progressRemaining(String amount);

  /// No description provided for @progressTotal.
  ///
  /// In es, this message translates to:
  /// **'Total {amount}'**
  String progressTotal(String amount);

  /// No description provided for @sheetDispensingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Despachando…'**
  String get sheetDispensingEllipsis;

  /// No description provided for @sheetAddedProgress.
  ///
  /// In es, this message translates to:
  /// **'+{volume} {unit} cargados'**
  String sheetAddedProgress(String volume, String unit);

  /// No description provided for @sheetAddedDone.
  ///
  /// In es, this message translates to:
  /// **'+{volume} {unit} · {amount}'**
  String sheetAddedDone(String volume, String unit, String amount);

  /// No description provided for @hintStill.
  ///
  /// In es, this message translates to:
  /// **'No muevas el auto ni enciendas el motor hasta colgar la manguera.'**
  String get hintStill;

  /// No description provided for @hintGnv.
  ///
  /// In es, this message translates to:
  /// **'No muevas el auto ni enciendas el motor hasta colgar la manguera. Presión del cilindro: 200 bar.'**
  String get hintGnv;

  /// No description provided for @hintHangUp.
  ///
  /// In es, this message translates to:
  /// **'Cuelga la manguera para cerrar la carga y generar tu comprobante.'**
  String get hintHangUp;

  /// No description provided for @sheetStop.
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get sheetStop;

  /// No description provided for @sheetHangUp.
  ///
  /// In es, this message translates to:
  /// **'Colgar manguera'**
  String get sheetHangUp;

  /// No description provided for @safetyTitle.
  ///
  /// In es, this message translates to:
  /// **'Antes de cargar GNV'**
  String get safetyTitle;

  /// No description provided for @safetySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma las medidas de seguridad del grifo.'**
  String get safetySubtitle;

  /// No description provided for @safetyPassengersOut.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros fuera del vehículo'**
  String get safetyPassengersOut;

  /// No description provided for @safetyEngineOff.
  ///
  /// In es, this message translates to:
  /// **'Motor y celular apagados'**
  String get safetyEngineOff;

  /// No description provided for @safetyNoSmoking.
  ///
  /// In es, this message translates to:
  /// **'Nadie fuma cerca del surtidor'**
  String get safetyNoSmoking;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @safetyStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar carga'**
  String get safetyStart;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @summaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de carga'**
  String get summaryTitle;

  /// No description provided for @summaryDone.
  ///
  /// In es, this message translates to:
  /// **'Carga completada'**
  String get summaryDone;

  /// No description provided for @summaryDoneSub.
  ///
  /// In es, this message translates to:
  /// **'Manguera colgada · listo para seguir'**
  String get summaryDoneSub;

  /// No description provided for @summaryLoaded.
  ///
  /// In es, this message translates to:
  /// **'cargado'**
  String get summaryLoaded;

  /// No description provided for @summaryBefore.
  ///
  /// In es, this message translates to:
  /// **'Antes'**
  String get summaryBefore;

  /// No description provided for @summaryNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get summaryNow;

  /// No description provided for @summaryVolume.
  ///
  /// In es, this message translates to:
  /// **'Volumen'**
  String get summaryVolume;

  /// No description provided for @summaryStation.
  ///
  /// In es, this message translates to:
  /// **'Grifo'**
  String get summaryStation;

  /// No description provided for @summaryDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get summaryDate;

  /// No description provided for @summaryPump.
  ///
  /// In es, this message translates to:
  /// **'Surtidor'**
  String get summaryPump;

  /// No description provided for @summaryIgv.
  ///
  /// In es, this message translates to:
  /// **'IGV (18%)'**
  String get summaryIgv;

  /// No description provided for @receiptTaxable.
  ///
  /// In es, this message translates to:
  /// **'Op. gravada'**
  String get receiptTaxable;

  /// No description provided for @receiptTotalWord.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get receiptTotalWord;

  /// No description provided for @summaryDocument.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get summaryDocument;

  /// No description provided for @summaryPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Medio de pago'**
  String get summaryPaymentMethod;

  /// No description provided for @summaryPay.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get summaryPay;

  /// No description provided for @documentBoleta.
  ///
  /// In es, this message translates to:
  /// **'Boleta'**
  String get documentBoleta;

  /// No description provided for @documentFactura.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get documentFactura;

  /// No description provided for @documentBoletaLower.
  ///
  /// In es, this message translates to:
  /// **'boleta'**
  String get documentBoletaLower;

  /// No description provided for @documentFacturaLower.
  ///
  /// In es, this message translates to:
  /// **'factura'**
  String get documentFacturaLower;

  /// No description provided for @fieldDni.
  ///
  /// In es, this message translates to:
  /// **'DNI'**
  String get fieldDni;

  /// No description provided for @fieldName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get fieldName;

  /// No description provided for @fieldRuc.
  ///
  /// In es, this message translates to:
  /// **'RUC'**
  String get fieldRuc;

  /// No description provided for @fieldBusinessName.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get fieldBusinessName;

  /// No description provided for @paymentVisaCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta Visa'**
  String get paymentVisaCard;

  /// No description provided for @confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get confirmTitle;

  /// No description provided for @confirmPayWith.
  ///
  /// In es, this message translates to:
  /// **'Pagar con'**
  String get confirmPayWith;

  /// No description provided for @confirmDocument.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get confirmDocument;

  /// No description provided for @confirmProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get confirmProduct;

  /// No description provided for @confirmBoleta.
  ///
  /// In es, this message translates to:
  /// **'Boleta · DNI {id}'**
  String confirmBoleta(String id);

  /// No description provided for @confirmFactura.
  ///
  /// In es, this message translates to:
  /// **'Factura · RUC {id}'**
  String confirmFactura(String id);

  /// No description provided for @confirmYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, pagar'**
  String get confirmYes;

  /// No description provided for @processingTitle.
  ///
  /// In es, this message translates to:
  /// **'Procesando pago'**
  String get processingTitle;

  /// No description provided for @processingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{amount} con {method}'**
  String processingSubtitle(String amount, String method);

  /// No description provided for @successTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Pago exitoso!'**
  String get successTitle;

  /// No description provided for @successSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{amount} pagado con {method}'**
  String successSubtitle(String amount, String method);

  /// No description provided for @successPoints.
  ///
  /// In es, this message translates to:
  /// **'+{points} puntos Tankeo'**
  String successPoints(int points);

  /// No description provided for @successAsk.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres ver tu {document}?'**
  String successAsk(String document);

  /// No description provided for @successNo.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get successNo;

  /// No description provided for @successView.
  ///
  /// In es, this message translates to:
  /// **'Ver {document}'**
  String successView(String document);

  /// No description provided for @receiptYourBoleta.
  ///
  /// In es, this message translates to:
  /// **'Tu boleta'**
  String get receiptYourBoleta;

  /// No description provided for @receiptYourFactura.
  ///
  /// In es, this message translates to:
  /// **'Tu factura'**
  String get receiptYourFactura;

  /// No description provided for @receiptPrinting.
  ///
  /// In es, this message translates to:
  /// **'Imprimiendo…'**
  String get receiptPrinting;

  /// No description provided for @receiptPaidWith.
  ///
  /// In es, this message translates to:
  /// **'{amount} pagado con {method}'**
  String receiptPaidWith(String amount, String method);

  /// No description provided for @receiptShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get receiptShare;

  /// No description provided for @receiptDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get receiptDone;

  /// No description provided for @receiptBoletaTitle.
  ///
  /// In es, this message translates to:
  /// **'BOLETA DE VENTA ELECTRÓNICA'**
  String get receiptBoletaTitle;

  /// No description provided for @receiptFacturaTitle.
  ///
  /// In es, this message translates to:
  /// **'FACTURA ELECTRÓNICA'**
  String get receiptFacturaTitle;

  /// No description provided for @receiptDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get receiptDate;

  /// No description provided for @receiptPump.
  ///
  /// In es, this message translates to:
  /// **'Surtidor'**
  String get receiptPump;

  /// No description provided for @receiptDescription.
  ///
  /// In es, this message translates to:
  /// **'DESCRIPCIÓN'**
  String get receiptDescription;

  /// No description provided for @receiptQty.
  ///
  /// In es, this message translates to:
  /// **'CANT.'**
  String get receiptQty;

  /// No description provided for @receiptUnitPrice.
  ///
  /// In es, this message translates to:
  /// **'P.U.'**
  String get receiptUnitPrice;

  /// No description provided for @receiptAmount.
  ///
  /// In es, this message translates to:
  /// **'IMPORTE'**
  String get receiptAmount;

  /// No description provided for @receiptIgv.
  ///
  /// In es, this message translates to:
  /// **'IGV 18%'**
  String get receiptIgv;

  /// No description provided for @receiptTotal.
  ///
  /// In es, this message translates to:
  /// **'IMPORTE TOTAL'**
  String get receiptTotal;

  /// No description provided for @receiptPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get receiptPaymentMethod;

  /// No description provided for @receiptQrSemantic.
  ///
  /// In es, this message translates to:
  /// **'Código QR del comprobante'**
  String get receiptQrSemantic;

  /// No description provided for @receiptLegal.
  ///
  /// In es, this message translates to:
  /// **'Representación impresa del comprobante electrónico.\nPrototipo Tankeo · datos de ejemplo, sin valor tributario.'**
  String get receiptLegal;

  /// No description provided for @receiptPaid.
  ///
  /// In es, this message translates to:
  /// **'PAGADO'**
  String get receiptPaid;

  /// No description provided for @errRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get errRetry;

  /// No description provided for @errPumpTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión con el surtidor {pump}'**
  String errPumpTitle(String pump);

  /// No description provided for @errPumpBody.
  ///
  /// In es, this message translates to:
  /// **'El surtidor no respondió. No se te cobró nada y la manguera sigue bloqueada.'**
  String get errPumpBody;

  /// No description provided for @errPumpOther.
  ///
  /// In es, this message translates to:
  /// **'Usar otro surtidor'**
  String get errPumpOther;

  /// No description provided for @errCertTitle.
  ///
  /// In es, this message translates to:
  /// **'Carga de GNV bloqueada'**
  String get errCertTitle;

  /// No description provided for @errCertBodyA.
  ///
  /// In es, this message translates to:
  /// **'Infogas indica que la certificación anual de tu cilindro '**
  String get errCertBodyA;

  /// No description provided for @errCertBodyB.
  ///
  /// In es, this message translates to:
  /// **'venció el {date}'**
  String errCertBodyB(String date);

  /// No description provided for @errCertBodyC.
  ///
  /// In es, this message translates to:
  /// **'. Renuévala en un taller autorizado para volver a cargar GNV.'**
  String get errCertBodyC;

  /// No description provided for @errCertGasoline.
  ///
  /// In es, this message translates to:
  /// **'Cargar gasolina'**
  String get errCertGasoline;

  /// No description provided for @errCertView.
  ///
  /// In es, this message translates to:
  /// **'Ver certificación'**
  String get errCertView;

  /// No description provided for @errPayTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago rechazado'**
  String get errPayTitle;

  /// No description provided for @errPayBodyA.
  ///
  /// In es, this message translates to:
  /// **'{method} no autorizó el cargo de '**
  String errPayBodyA(String method);

  /// No description provided for @errPayBodyC.
  ///
  /// In es, this message translates to:
  /// **'. No se te cobró nada.'**
  String get errPayBodyC;

  /// No description provided for @errPayChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar método'**
  String get errPayChange;

  /// No description provided for @queueTitleBusy.
  ///
  /// In es, this message translates to:
  /// **'Todos los surtidores están ocupados'**
  String get queueTitleBusy;

  /// No description provided for @queueTitleReady.
  ///
  /// In es, this message translates to:
  /// **'¡Surtidor {pump} libre!'**
  String queueTitleReady(String pump);

  /// No description provided for @queueSubWait.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos apenas se libere uno. Espera aprox. {min} min.'**
  String queueSubWait(int min);

  /// No description provided for @queueSubReady.
  ///
  /// In es, this message translates to:
  /// **'Acércate a la {isle}. Tienes 3 min para autorizar.'**
  String queueSubReady(String isle);

  /// No description provided for @queueInQueue.
  ///
  /// In es, this message translates to:
  /// **'en la cola'**
  String get queueInQueue;

  /// No description provided for @queueYourTurn.
  ///
  /// In es, this message translates to:
  /// **'te toca'**
  String get queueYourTurn;

  /// No description provided for @queueAhead.
  ///
  /// In es, this message translates to:
  /// **'Autos antes que tú'**
  String get queueAhead;

  /// No description provided for @queueStation.
  ///
  /// In es, this message translates to:
  /// **'Grifo'**
  String get queueStation;

  /// No description provided for @queueLeave.
  ///
  /// In es, this message translates to:
  /// **'Salir de la cola'**
  String get queueLeave;

  /// No description provided for @queueWaiting.
  ///
  /// In es, this message translates to:
  /// **'Esperando…'**
  String get queueWaiting;

  /// No description provided for @queueGo.
  ///
  /// In es, this message translates to:
  /// **'Ir al surtidor'**
  String get queueGo;

  /// No description provided for @simTitle.
  ///
  /// In es, this message translates to:
  /// **'Simular errores'**
  String get simTitle;

  /// No description provided for @simCert.
  ///
  /// In es, this message translates to:
  /// **'Certificación GNV vencida'**
  String get simCert;

  /// No description provided for @simCertSub.
  ///
  /// In es, this message translates to:
  /// **'bloquea la carga de GNV'**
  String get simCertSub;

  /// No description provided for @simPump.
  ///
  /// In es, this message translates to:
  /// **'Surtidor sin conexión'**
  String get simPump;

  /// No description provided for @simPumpSub.
  ///
  /// In es, this message translates to:
  /// **'una vez, al autorizar'**
  String get simPumpSub;

  /// No description provided for @simPay.
  ///
  /// In es, this message translates to:
  /// **'Pago rechazado'**
  String get simPay;

  /// No description provided for @simPaySub.
  ///
  /// In es, this message translates to:
  /// **'una vez, al pagar'**
  String get simPaySub;

  /// No description provided for @certExpiredBadge.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get certExpiredBadge;

  /// No description provided for @certExpiredOn.
  ///
  /// In es, this message translates to:
  /// **'Anual venció'**
  String get certExpiredOn;

  /// No description provided for @certRenew.
  ///
  /// In es, this message translates to:
  /// **'Renovar'**
  String get certRenew;

  /// No description provided for @filterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filterTitle;

  /// No description provided for @filterClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get filterClear;

  /// No description provided for @filterFree.
  ///
  /// In es, this message translates to:
  /// **'Con surtidores libres'**
  String get filterFree;

  /// No description provided for @filterFreeSub.
  ///
  /// In es, this message translates to:
  /// **'Oculta los grifos llenos'**
  String get filterFreeSub;

  /// No description provided for @filterApp.
  ///
  /// In es, this message translates to:
  /// **'Pago desde la app'**
  String get filterApp;

  /// No description provided for @filterAppSub.
  ///
  /// In es, this message translates to:
  /// **'Yape, Plin o tarjeta en el surtidor'**
  String get filterAppSub;

  /// No description provided for @filterDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia máxima'**
  String get filterDistance;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @filterServices.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get filterServices;

  /// No description provided for @filterShow.
  ///
  /// In es, this message translates to:
  /// **'Mostrar {count} {stations}'**
  String filterShow(int count, String stations);

  /// No description provided for @filterStationOne.
  ///
  /// In es, this message translates to:
  /// **'grifo'**
  String get filterStationOne;

  /// No description provided for @filterStationMany.
  ///
  /// In es, this message translates to:
  /// **'grifos'**
  String get filterStationMany;

  /// No description provided for @filterNone.
  ///
  /// In es, this message translates to:
  /// **'Ningún grifo coincide'**
  String get filterNone;

  /// No description provided for @toastFiltersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} {what}'**
  String toastFiltersCount(int count, String what);

  /// No description provided for @toastFiltersMatchOne.
  ///
  /// In es, this message translates to:
  /// **'grifo coincide.'**
  String get toastFiltersMatchOne;

  /// No description provided for @toastFiltersMatchMany.
  ///
  /// In es, this message translates to:
  /// **'grifos coinciden.'**
  String get toastFiltersMatchMany;

  /// No description provided for @toastHiddenByFilters.
  ///
  /// In es, this message translates to:
  /// **'Ese grifo está oculto por tus filtros.'**
  String get toastHiddenByFilters;

  /// No description provided for @toastNewPump.
  ///
  /// In es, this message translates to:
  /// **'Te asignamos el surtidor {pump}.'**
  String toastNewPump(String pump);

  /// No description provided for @toastLeftQueue.
  ///
  /// In es, this message translates to:
  /// **'Saliste de la cola.'**
  String get toastLeftQueue;

  /// No description provided for @toastPickAnotherMethod.
  ///
  /// In es, this message translates to:
  /// **'Elige otro método y vuelve a pagar.'**
  String get toastPickAnotherMethod;

  /// No description provided for @toastDieselInfo.
  ///
  /// In es, this message translates to:
  /// **'Tu McLaren F1 no usa diésel: solo verás los precios.'**
  String get toastDieselInfo;

  /// No description provided for @toastFinishCurrentCharge.
  ///
  /// In es, this message translates to:
  /// **'Termina tu carga actual antes de ir a otro grifo.'**
  String get toastFinishCurrentCharge;

  /// No description provided for @toastPayPreviousFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero paga tu carga anterior.'**
  String get toastPayPreviousFirst;

  /// No description provided for @toastArrived.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a {station}. Surtidor {pump} asignado.'**
  String toastArrived(String station, String pump);

  /// No description provided for @toastGridBusy.
  ///
  /// In es, this message translates to:
  /// **'Todos los surtidores están ocupados: espera aprox. 6 min.'**
  String get toastGridBusy;

  /// No description provided for @toastChipValidated.
  ///
  /// In es, this message translates to:
  /// **'Chip Infogas validado · cilindro con certificación vigente.'**
  String get toastChipValidated;

  /// No description provided for @toastChargeComplete.
  ///
  /// In es, this message translates to:
  /// **'Carga completa. Cuelga la manguera para pagar.'**
  String get toastChargeComplete;

  /// No description provided for @toastGnvPreferred.
  ///
  /// In es, this message translates to:
  /// **'El auto usará GNV y cambiará a gasolina si se acaba.'**
  String get toastGnvPreferred;

  /// No description provided for @toastGasolineOnly.
  ///
  /// In es, this message translates to:
  /// **'El auto usará solo gasolina.'**
  String get toastGasolineOnly;

  /// No description provided for @toastStationShared.
  ///
  /// In es, this message translates to:
  /// **'Ubicación de {station} copiada.'**
  String toastStationShared(String station);

  /// No description provided for @toastFavoriteAdded.
  ///
  /// In es, this message translates to:
  /// **'Grifo guardado en favoritos.'**
  String get toastFavoriteAdded;

  /// No description provided for @toastFavoriteRemoved.
  ///
  /// In es, this message translates to:
  /// **'Quitado de favoritos.'**
  String get toastFavoriteRemoved;

  /// No description provided for @toastFiltersInfo.
  ///
  /// In es, this message translates to:
  /// **'Filtros: abierto ahora · pago en app'**
  String get toastFiltersInfo;

  /// No description provided for @toastSettingsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Ajustes todavía no está disponible.'**
  String get toastSettingsUnavailable;

  /// No description provided for @toastInvalidDni.
  ///
  /// In es, this message translates to:
  /// **'El DNI debe tener 8 dígitos.'**
  String get toastInvalidDni;

  /// No description provided for @toastInvalidRuc.
  ///
  /// In es, this message translates to:
  /// **'El RUC debe tener 11 dígitos y empezar con 10 o 20.'**
  String get toastInvalidRuc;

  /// No description provided for @toastReceiptShared.
  ///
  /// In es, this message translates to:
  /// **'Comprobante listo para compartir (PDF y XML).'**
  String get toastReceiptShared;

  /// No description provided for @toastPaidByEmail.
  ///
  /// In es, this message translates to:
  /// **'Pagaste {amount}. Te enviamos la {document} por correo.'**
  String toastPaidByEmail(String amount, String document);

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @soles.
  ///
  /// In es, this message translates to:
  /// **'S/'**
  String get soles;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @notificationsReadAll.
  ///
  /// In es, this message translates to:
  /// **'Leer todo'**
  String get notificationsReadAll;

  /// No description provided for @notificationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes avisos nuevos.'**
  String get notificationsEmpty;

  /// No description provided for @notifCertTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificación por vencer'**
  String get notifCertTitle;

  /// No description provided for @notifCertBody.
  ///
  /// In es, this message translates to:
  /// **'Tu certificación anual de GNV vence el {date}. Agenda tu renovación.'**
  String notifCertBody(String date);

  /// No description provided for @notifPriceTitle.
  ///
  /// In es, this message translates to:
  /// **'Bajó el precio del GNV'**
  String get notifPriceTitle;

  /// No description provided for @notifPriceBody.
  ///
  /// In es, this message translates to:
  /// **'GNV a {price} en {station}. Es el más barato cerca de ti.'**
  String notifPriceBody(String price, String station);

  /// No description provided for @notifPaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago registrado'**
  String get notifPaymentTitle;

  /// No description provided for @notifPaymentBody.
  ///
  /// In es, this message translates to:
  /// **'Pagaste {amount} en {station}. Tu {document} ya está disponible.'**
  String notifPaymentBody(String amount, String station, String document);

  /// No description provided for @notifPointsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ganaste {points} puntos'**
  String notifPointsTitle(int points);

  /// No description provided for @notifPointsBody.
  ///
  /// In es, this message translates to:
  /// **'Por tu última carga. Ya tienes {balance} puntos Tankeo.'**
  String notifPointsBody(String balance);

  /// No description provided for @notifApptTitle.
  ///
  /// In es, this message translates to:
  /// **'Cita confirmada'**
  String get notifApptTitle;

  /// No description provided for @notifApptBody.
  ///
  /// In es, this message translates to:
  /// **'Renovación en {shop}, {day} a las {time}.'**
  String notifApptBody(String shop, String day, String time);

  /// No description provided for @timeNow.
  ///
  /// In es, this message translates to:
  /// **'ahora'**
  String get timeNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {n} min'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {n} h'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {n} d'**
  String timeDaysAgo(int n);

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de cargas'**
  String get historyTitle;

  /// No description provided for @historyMonthTotal.
  ///
  /// In es, this message translates to:
  /// **'Gastado en {month}'**
  String historyMonthTotal(String month);

  /// No description provided for @historyChargesCount.
  ///
  /// In es, this message translates to:
  /// **'{n} cargas'**
  String historyChargesCount(int n);

  /// No description provided for @historyGnvShare.
  ///
  /// In es, this message translates to:
  /// **'{pct} % con GNV'**
  String historyGnvShare(int pct);

  /// No description provided for @filterInvoices.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get filterInvoices;

  /// No description provided for @historyNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get historyNew;

  /// No description provided for @historyEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay cargas con este filtro.'**
  String get historyEmpty;

  /// No description provided for @historyDocLine.
  ///
  /// In es, this message translates to:
  /// **'{document} · {volume} {unit}'**
  String historyDocLine(String document, String volume, String unit);

  /// No description provided for @certScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificación GNV'**
  String get certScreenTitle;

  /// No description provided for @certStatusValid.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get certStatusValid;

  /// No description provided for @certStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get certStatusExpired;

  /// No description provided for @certDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'{n} días restantes'**
  String certDaysLeft(int n);

  /// No description provided for @certExpiredDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Venció hace {n} días'**
  String certExpiredDaysAgo(int n);

  /// No description provided for @certDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del cilindro'**
  String get certDataTitle;

  /// No description provided for @certChip.
  ///
  /// In es, this message translates to:
  /// **'Chip Infogas'**
  String get certChip;

  /// No description provided for @certCylinderLabel.
  ///
  /// In es, this message translates to:
  /// **'Cilindro'**
  String get certCylinderLabel;

  /// No description provided for @certShop.
  ///
  /// In es, this message translates to:
  /// **'Taller'**
  String get certShop;

  /// No description provided for @certValidUntil.
  ///
  /// In es, this message translates to:
  /// **'Vigente hasta'**
  String get certValidUntil;

  /// No description provided for @certNextReview.
  ///
  /// In es, this message translates to:
  /// **'Próxima revisión'**
  String get certNextReview;

  /// No description provided for @certTimeline.
  ///
  /// In es, this message translates to:
  /// **'Historial de inspecciones'**
  String get certTimeline;

  /// No description provided for @certInspectionAnnual.
  ///
  /// In es, this message translates to:
  /// **'Inspección anual'**
  String get certInspectionAnnual;

  /// No description provided for @certInspectionConversion.
  ///
  /// In es, this message translates to:
  /// **'Conversión e instalación'**
  String get certInspectionConversion;

  /// No description provided for @certApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get certApproved;

  /// No description provided for @certSchedule.
  ///
  /// In es, this message translates to:
  /// **'Agendar renovación'**
  String get certSchedule;

  /// No description provided for @certScheduled.
  ///
  /// In es, this message translates to:
  /// **'Cita agendada'**
  String get certScheduled;

  /// No description provided for @certScheduledBody.
  ///
  /// In es, this message translates to:
  /// **'{shop} · {day}, {time}'**
  String certScheduledBody(String shop, String day, String time);

  /// No description provided for @certScheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Agendar renovación'**
  String get certScheduleTitle;

  /// No description provided for @certScheduleShop.
  ///
  /// In es, this message translates to:
  /// **'Taller'**
  String get certScheduleShop;

  /// No description provided for @certScheduleDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get certScheduleDay;

  /// No description provided for @certScheduleTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get certScheduleTime;

  /// No description provided for @certScheduleConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cita'**
  String get certScheduleConfirm;

  /// No description provided for @shopSurco.
  ///
  /// In es, this message translates to:
  /// **'GNV Autorizado Surco'**
  String get shopSurco;

  /// No description provided for @shopMiraflores.
  ///
  /// In es, this message translates to:
  /// **'Taller Infogas Miraflores'**
  String get shopMiraflores;

  /// No description provided for @shopLince.
  ///
  /// In es, this message translates to:
  /// **'Centro GNV Lince'**
  String get shopLince;

  /// No description provided for @weekdayShort.
  ///
  /// In es, this message translates to:
  /// **'dom,lun,mar,mié,jue,vie,sáb'**
  String get weekdayShort;

  /// No description provided for @toastApptConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Cita confirmada en {shop}.'**
  String toastApptConfirmed(String shop);

  /// No description provided for @pointsTitle.
  ///
  /// In es, this message translates to:
  /// **'Puntos Tankeo'**
  String get pointsTitle;

  /// No description provided for @pointsBalance.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo'**
  String get pointsBalance;

  /// No description provided for @pointsUnit.
  ///
  /// In es, this message translates to:
  /// **'puntos'**
  String get pointsUnit;

  /// No description provided for @pointsTierSilver.
  ///
  /// In es, this message translates to:
  /// **'Nivel Plata'**
  String get pointsTierSilver;

  /// No description provided for @pointsTierGold.
  ///
  /// In es, this message translates to:
  /// **'Nivel Oro'**
  String get pointsTierGold;

  /// No description provided for @pointsToGold.
  ///
  /// In es, this message translates to:
  /// **'{n} puntos para Oro'**
  String pointsToGold(String n);

  /// No description provided for @pointsRule.
  ///
  /// In es, this message translates to:
  /// **'Ganas 1 punto por cada S/ 1 cargado.'**
  String get pointsRule;

  /// No description provided for @pointsRedeem.
  ///
  /// In es, this message translates to:
  /// **'Canjea'**
  String get pointsRedeem;

  /// No description provided for @pointsMovements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get pointsMovements;

  /// No description provided for @pointsMissing.
  ///
  /// In es, this message translates to:
  /// **'Faltan {n}'**
  String pointsMissing(String n);

  /// No description provided for @pointsRewardGnv.
  ///
  /// In es, this message translates to:
  /// **'S/ 5 en GNV'**
  String get pointsRewardGnv;

  /// No description provided for @pointsRewardCoffee.
  ///
  /// In es, this message translates to:
  /// **'Café en tienda'**
  String get pointsRewardCoffee;

  /// No description provided for @pointsRewardWash.
  ///
  /// In es, this message translates to:
  /// **'Lavado de auto'**
  String get pointsRewardWash;

  /// No description provided for @pointsRewardGasoline.
  ///
  /// In es, this message translates to:
  /// **'S/ 20 en gasolina'**
  String get pointsRewardGasoline;

  /// No description provided for @pointsCost.
  ///
  /// In es, this message translates to:
  /// **'{n} pts'**
  String pointsCost(String n);

  /// No description provided for @redeemTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Canjear {reward}?'**
  String redeemTitle(String reward);

  /// No description provided for @redeemBody.
  ///
  /// In es, this message translates to:
  /// **'Se descontarán {cost} puntos. Te quedarán {left}.'**
  String redeemBody(String cost, String left);

  /// No description provided for @redeemConfirm.
  ///
  /// In es, this message translates to:
  /// **'Canjear'**
  String get redeemConfirm;

  /// No description provided for @toastRedeemed.
  ///
  /// In es, this message translates to:
  /// **'Canje listo. Tu código es {code}.'**
  String toastRedeemed(String code);

  /// No description provided for @movementCharge.
  ///
  /// In es, this message translates to:
  /// **'Carga en {station}'**
  String movementCharge(String station);

  /// No description provided for @movementWelcome.
  ///
  /// In es, this message translates to:
  /// **'Regalo de bienvenida'**
  String get movementWelcome;

  /// No description provided for @movementRedeem.
  ///
  /// In es, this message translates to:
  /// **'Canje: {reward}'**
  String movementRedeem(String reward);

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get settingsAccount;

  /// No description provided for @settingsPrefs.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsPrefs;

  /// No description provided for @settingsSupport.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get settingsSupport;

  /// No description provided for @settingsVehicles.
  ///
  /// In es, this message translates to:
  /// **'Mis vehículos'**
  String get settingsVehicles;

  /// No description provided for @settingsPayments.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get settingsPayments;

  /// No description provided for @settingsBilling.
  ///
  /// In es, this message translates to:
  /// **'Datos de facturación'**
  String get settingsBilling;

  /// No description provided for @settingsHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de cargas'**
  String get settingsHistory;

  /// No description provided for @settingsCert.
  ///
  /// In es, this message translates to:
  /// **'Certificación GNV'**
  String get settingsCert;

  /// No description provided for @settingsPoints.
  ///
  /// In es, this message translates to:
  /// **'Puntos Tankeo'**
  String get settingsPoints;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsPriceAlerts.
  ///
  /// In es, this message translates to:
  /// **'Avisos de bajada de precio'**
  String get settingsPriceAlerts;

  /// No description provided for @settingsCertReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de certificación'**
  String get settingsCertReminder;

  /// No description provided for @settingsPreferredFuel.
  ///
  /// In es, this message translates to:
  /// **'Combustible preferido'**
  String get settingsPreferredFuel;

  /// No description provided for @settingsHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y contacto'**
  String get settingsHelp;

  /// No description provided for @settingsLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Tankeo 1.0'**
  String get settingsVersion;

  /// No description provided for @settingsCredits.
  ///
  /// In es, this message translates to:
  /// **'Modelo 3D «McLaren F1 1993» de Alex.Ka. (Sketchfab) · CC BY-NC 4.0'**
  String get settingsCredits;

  /// No description provided for @profilePoints.
  ///
  /// In es, this message translates to:
  /// **'{n} pts'**
  String profilePoints(String n);

  /// No description provided for @profilePhone.
  ///
  /// In es, this message translates to:
  /// **'+51 987 654 321'**
  String get profilePhone;

  /// No description provided for @logoutTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que volver a ingresar para cargar desde tu auto.'**
  String get logoutBody;

  /// No description provided for @logoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutConfirm;

  /// No description provided for @toastHelp.
  ///
  /// In es, this message translates to:
  /// **'Escríbenos a ayuda@tankeo.pe y te respondemos en minutos.'**
  String get toastHelp;

  /// No description provided for @vehiclesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis vehículos'**
  String get vehiclesTitle;

  /// No description provided for @vehicleInUse.
  ///
  /// In es, this message translates to:
  /// **'En uso'**
  String get vehicleInUse;

  /// No description provided for @vehicleAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo'**
  String get vehicleAdd;

  /// No description provided for @vehicleTankGas.
  ///
  /// In es, this message translates to:
  /// **'Tanque {pct} %'**
  String vehicleTankGas(int pct);

  /// No description provided for @vehicleTankGnv.
  ///
  /// In es, this message translates to:
  /// **'Cilindro {pct} %'**
  String vehicleTankGnv(int pct);

  /// No description provided for @vehicleCertOk.
  ///
  /// In es, this message translates to:
  /// **'Certificación vigente'**
  String get vehicleCertOk;

  /// No description provided for @vehicleCertNone.
  ///
  /// In es, this message translates to:
  /// **'Sin GNV'**
  String get vehicleCertNone;

  /// No description provided for @vehicleFuelDual.
  ///
  /// In es, this message translates to:
  /// **'Dual gasolina + GNV'**
  String get vehicleFuelDual;

  /// No description provided for @vehicleFuelGasoline.
  ///
  /// In es, this message translates to:
  /// **'Solo gasolina'**
  String get vehicleFuelGasoline;

  /// No description provided for @vehicleFuelGnv.
  ///
  /// In es, this message translates to:
  /// **'Solo GNV'**
  String get vehicleFuelGnv;

  /// No description provided for @vehicleFuelDualShort.
  ///
  /// In es, this message translates to:
  /// **'Dual'**
  String get vehicleFuelDualShort;

  /// No description provided for @vehicleUse.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get vehicleUse;

  /// No description provided for @paymentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get paymentsTitle;

  /// No description provided for @paymentDefault.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get paymentDefault;

  /// No description provided for @paymentUse.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get paymentUse;

  /// No description provided for @paymentRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get paymentRemove;

  /// No description provided for @paymentAddCard.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarjeta'**
  String get paymentAddCard;

  /// No description provided for @paymentSecurityNote.
  ///
  /// In es, this message translates to:
  /// **'Tus tarjetas se guardan cifradas: solo conservamos un token y los últimos 4 dígitos.'**
  String get paymentSecurityNote;

  /// No description provided for @paymentYapeLabel.
  ///
  /// In es, this message translates to:
  /// **'Yape'**
  String get paymentYapeLabel;

  /// No description provided for @paymentPlinLabel.
  ///
  /// In es, this message translates to:
  /// **'Plin'**
  String get paymentPlinLabel;

  /// No description provided for @paymentCardDetail.
  ///
  /// In es, this message translates to:
  /// **'Vence {date}'**
  String paymentCardDetail(String date);

  /// No description provided for @paymentPhoneDetail.
  ///
  /// In es, this message translates to:
  /// **'Celular •••• {last}'**
  String paymentPhoneDetail(String last);

  /// No description provided for @toastPaymentDefault.
  ///
  /// In es, this message translates to:
  /// **'{method} es tu método predeterminado.'**
  String toastPaymentDefault(String method);

  /// No description provided for @toastPaymentRemoved.
  ///
  /// In es, this message translates to:
  /// **'Método quitado.'**
  String get toastPaymentRemoved;

  /// No description provided for @toastPaymentLast.
  ///
  /// In es, this message translates to:
  /// **'Debes conservar al menos un método de pago.'**
  String get toastPaymentLast;

  /// No description provided for @toastCardAdded.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta agregada.'**
  String get toastCardAdded;

  /// No description provided for @cardTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarjeta'**
  String get cardTitle;

  /// No description provided for @cardNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In es, this message translates to:
  /// **'MM/AA'**
  String get cardExpiry;

  /// No description provided for @cardCvv.
  ///
  /// In es, this message translates to:
  /// **'CVV'**
  String get cardCvv;

  /// No description provided for @cardHolder.
  ///
  /// In es, this message translates to:
  /// **'Titular de la tarjeta'**
  String get cardHolder;

  /// No description provided for @cardHolderPreview.
  ///
  /// In es, this message translates to:
  /// **'TITULAR'**
  String get cardHolderPreview;

  /// No description provided for @cardSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar tarjeta'**
  String get cardSave;

  /// No description provided for @errCardNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta no válido.'**
  String get errCardNumber;

  /// No description provided for @errCardExpiry.
  ///
  /// In es, this message translates to:
  /// **'Fecha vencida o no válida.'**
  String get errCardExpiry;

  /// No description provided for @errCardCvv.
  ///
  /// In es, this message translates to:
  /// **'CVV de 3 o 4 dígitos.'**
  String get errCardCvv;

  /// No description provided for @errCardHolder.
  ///
  /// In es, this message translates to:
  /// **'Escribe nombre y apellido.'**
  String get errCardHolder;

  /// No description provided for @cardBrandVisa.
  ///
  /// In es, this message translates to:
  /// **'Visa'**
  String get cardBrandVisa;

  /// No description provided for @cardBrandMastercard.
  ///
  /// In es, this message translates to:
  /// **'Mastercard'**
  String get cardBrandMastercard;

  /// No description provided for @cardBrandAmex.
  ///
  /// In es, this message translates to:
  /// **'Amex'**
  String get cardBrandAmex;

  /// No description provided for @cardBrandCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get cardBrandCard;

  /// No description provided for @billingTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de facturación'**
  String get billingTitle;

  /// No description provided for @billingBoleta.
  ///
  /// In es, this message translates to:
  /// **'Para boletas'**
  String get billingBoleta;

  /// No description provided for @billingFactura.
  ///
  /// In es, this message translates to:
  /// **'Para facturas'**
  String get billingFactura;

  /// No description provided for @billingNote.
  ///
  /// In es, this message translates to:
  /// **'Se usarán para rellenar el comprobante en el resumen de carga.'**
  String get billingNote;

  /// No description provided for @toastBillingSaved.
  ///
  /// In es, this message translates to:
  /// **'Datos de facturación guardados.'**
  String get toastBillingSaved;

  /// No description provided for @signupTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get signupTitle;

  /// No description provided for @signupStepAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get signupStepAccount;

  /// No description provided for @signupStepVehicle.
  ///
  /// In es, this message translates to:
  /// **'Tu vehículo'**
  String get signupStepVehicle;

  /// No description provided for @signupStepGnv.
  ///
  /// In es, this message translates to:
  /// **'Tu cilindro GNV'**
  String get signupStepGnv;

  /// No description provided for @signupStepCounter.
  ///
  /// In es, this message translates to:
  /// **'{step}/{total}'**
  String signupStepCounter(int step, int total);

  /// No description provided for @signupName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get signupName;

  /// No description provided for @signupEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get signupEmail;

  /// No description provided for @signupPhone.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get signupPhone;

  /// No description provided for @signupPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get signupPassword;

  /// No description provided for @signupTerms.
  ///
  /// In es, this message translates to:
  /// **'Acepto los términos y la política de privacidad'**
  String get signupTerms;

  /// No description provided for @errName.
  ///
  /// In es, this message translates to:
  /// **'Escribe nombre y apellido.'**
  String get errName;

  /// No description provided for @errEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido.'**
  String get errEmail;

  /// No description provided for @errPhone.
  ///
  /// In es, this message translates to:
  /// **'Celular de 9 dígitos que empieza con 9.'**
  String get errPhone;

  /// No description provided for @errPassword.
  ///
  /// In es, this message translates to:
  /// **'Usa 8 caracteres, mayúscula y número.'**
  String get errPassword;

  /// No description provided for @errTerms.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos.'**
  String get errTerms;

  /// No description provided for @strengthWeak.
  ///
  /// In es, this message translates to:
  /// **'Débil'**
  String get strengthWeak;

  /// No description provided for @strengthMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get strengthMedium;

  /// No description provided for @strengthStrong.
  ///
  /// In es, this message translates to:
  /// **'Fuerte'**
  String get strengthStrong;

  /// No description provided for @vehicleName.
  ///
  /// In es, this message translates to:
  /// **'Marca y modelo'**
  String get vehicleName;

  /// No description provided for @vehiclePlate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get vehiclePlate;

  /// No description provided for @vehicleYear.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get vehicleYear;

  /// No description provided for @vehicleFuelType.
  ///
  /// In es, this message translates to:
  /// **'Combustible'**
  String get vehicleFuelType;

  /// No description provided for @vehicleTankCapacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad del tanque (gal)'**
  String get vehicleTankCapacity;

  /// No description provided for @vehicleCylinderCapacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad del cilindro (m³)'**
  String get vehicleCylinderCapacity;

  /// No description provided for @errVehicleName.
  ///
  /// In es, this message translates to:
  /// **'Escribe la marca y el modelo.'**
  String get errVehicleName;

  /// No description provided for @errPlate.
  ///
  /// In es, this message translates to:
  /// **'Placa con formato ABC-123.'**
  String get errPlate;

  /// No description provided for @errYear.
  ///
  /// In es, this message translates to:
  /// **'Año no válido.'**
  String get errYear;

  /// No description provided for @gnvChip.
  ///
  /// In es, this message translates to:
  /// **'Chip Infogas'**
  String get gnvChip;

  /// No description provided for @gnvChipHint.
  ///
  /// In es, this message translates to:
  /// **'0000-0000-00'**
  String get gnvChipHint;

  /// No description provided for @gnvExpiry.
  ///
  /// In es, this message translates to:
  /// **'Vence la certificación'**
  String get gnvExpiry;

  /// No description provided for @gnvExpiryHint.
  ///
  /// In es, this message translates to:
  /// **'dd/mm/aaaa'**
  String get gnvExpiryHint;

  /// No description provided for @gnvCylinderType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cilindro'**
  String get gnvCylinderType;

  /// No description provided for @gnvCylinderNote.
  ///
  /// In es, this message translates to:
  /// **'Los GNV-1 se revisan cada 5 años; los GNV-2 y GNV-4, cada 4.'**
  String get gnvCylinderNote;

  /// No description provided for @errChip.
  ///
  /// In es, this message translates to:
  /// **'Chip con formato 0000-0000-00.'**
  String get errChip;

  /// No description provided for @errExpiry.
  ///
  /// In es, this message translates to:
  /// **'Fecha no válida.'**
  String get errExpiry;

  /// No description provided for @signupNext.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get signupNext;

  /// No description provided for @signupStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar a usar Tankeo'**
  String get signupStart;

  /// No description provided for @signupAddFinish.
  ///
  /// In es, this message translates to:
  /// **'Guardar vehículo'**
  String get signupAddFinish;

  /// No description provided for @signupDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Listo, {name}!'**
  String signupDoneTitle(String name);

  /// No description provided for @signupDoneBody.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está creada. Empieza a cargar sin bajarte del auto.'**
  String get signupDoneBody;

  /// No description provided for @signupGift.
  ///
  /// In es, this message translates to:
  /// **'+{n} puntos de bienvenida'**
  String signupGift(int n);

  /// No description provided for @addVehicleTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo'**
  String get addVehicleTitle;

  /// No description provided for @resetTitle.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get resetTitle;

  /// No description provided for @resetEmailBody.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviamos un código de 4 dígitos.'**
  String get resetEmailBody;

  /// No description provided for @resetSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get resetSend;

  /// No description provided for @resetCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get resetCodeTitle;

  /// No description provided for @resetCodeBody.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código que enviamos a {email}.'**
  String resetCodeBody(String email);

  /// No description provided for @resetVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get resetVerify;

  /// No description provided for @resetResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resetResend;

  /// No description provided for @resetResendIn.
  ///
  /// In es, this message translates to:
  /// **'Reenviar en {n} s'**
  String resetResendIn(int n);

  /// No description provided for @resetWrongCode.
  ///
  /// In es, this message translates to:
  /// **'Código incorrecto. Te quedan {n} intentos.'**
  String resetWrongCode(int n);

  /// No description provided for @resetNoAttempts.
  ///
  /// In es, this message translates to:
  /// **'Sin intentos. Pide un código nuevo.'**
  String get resetNoAttempts;

  /// No description provided for @resetNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña nueva'**
  String get resetNewTitle;

  /// No description provided for @resetNewBody.
  ///
  /// In es, this message translates to:
  /// **'Usa una que no hayas usado antes.'**
  String get resetNewBody;

  /// No description provided for @resetNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get resetNewPassword;

  /// No description provided for @resetRepeatPassword.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get resetRepeatPassword;

  /// No description provided for @resetMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get resetMismatch;

  /// No description provided for @resetUpdate.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contraseña'**
  String get resetUpdate;

  /// No description provided for @toastPasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada.'**
  String get toastPasswordUpdated;

  /// No description provided for @toastCodeSent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un código nuevo.'**
  String get toastCodeSent;

  /// No description provided for @navTabCar.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get navTabCar;

  /// No description provided for @navTabFuel.
  ///
  /// In es, this message translates to:
  /// **'Carga'**
  String get navTabFuel;

  /// No description provided for @navTabStations.
  ///
  /// In es, this message translates to:
  /// **'Grifos'**
  String get navTabStations;

  /// No description provided for @navTabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navTabSettings;

  /// No description provided for @navFuelInProgress.
  ///
  /// In es, this message translates to:
  /// **'Carga en curso'**
  String get navFuelInProgress;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'{n} min'**
  String minutes(int n);

  /// No description provided for @navOverview.
  ///
  /// In es, this message translates to:
  /// **'Vista general'**
  String get navOverview;

  /// No description provided for @navTurnRight.
  ///
  /// In es, this message translates to:
  /// **'Gira a la derecha en {street}'**
  String navTurnRight(String street);

  /// No description provided for @navTurnLeft.
  ///
  /// In es, this message translates to:
  /// **'Gira a la izquierda en {street}'**
  String navTurnLeft(String street);

  /// No description provided for @navStraight.
  ///
  /// In es, this message translates to:
  /// **'Sigue recto por {street}'**
  String navStraight(String street);

  /// No description provided for @navDestination.
  ///
  /// In es, this message translates to:
  /// **'Tu destino: {station}'**
  String navDestination(String station);

  /// No description provided for @navThen.
  ///
  /// In es, this message translates to:
  /// **'Luego'**
  String get navThen;

  /// No description provided for @navInDistance.
  ///
  /// In es, this message translates to:
  /// **'En {distance}'**
  String navInDistance(String distance);

  /// No description provided for @navMeters.
  ///
  /// In es, this message translates to:
  /// **'{n} m'**
  String navMeters(int n);

  /// No description provided for @navKm.
  ///
  /// In es, this message translates to:
  /// **'{n} km'**
  String navKm(String n);

  /// No description provided for @navArrivedBanner.
  ///
  /// In es, this message translates to:
  /// **'Llegaste · Entra a la isla {isle} · surtidor {pump}'**
  String navArrivedBanner(String isle, String pump);

  /// No description provided for @navArrivedTitle.
  ///
  /// In es, this message translates to:
  /// **'Llegaste'**
  String get navArrivedTitle;

  /// No description provided for @navRemaining.
  ///
  /// In es, this message translates to:
  /// **'{distance} en {minutes} min'**
  String navRemaining(String distance, int minutes);

  /// No description provided for @navArrival.
  ///
  /// In es, this message translates to:
  /// **'llegada {time}'**
  String navArrival(String time);

  /// No description provided for @navContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar a la carga'**
  String get navContinue;

  /// No description provided for @navSlideContinue.
  ///
  /// In es, this message translates to:
  /// **'Desliza para ir a la carga'**
  String get navSlideContinue;

  /// No description provided for @navOverviewTag.
  ///
  /// In es, this message translates to:
  /// **'Vista general de la ruta'**
  String get navOverviewTag;

  /// No description provided for @navDistanceThen.
  ///
  /// In es, this message translates to:
  /// **'luego gira'**
  String get navDistanceThen;

  /// No description provided for @navTurnNow.
  ///
  /// In es, this message translates to:
  /// **'Gira ahora'**
  String get navTurnNow;

  /// No description provided for @navTurnLeftOn.
  ///
  /// In es, this message translates to:
  /// **'A la izquierda en {street}'**
  String navTurnLeftOn(String street);

  /// No description provided for @navTurnRightOn.
  ///
  /// In es, this message translates to:
  /// **'A la derecha en {street}'**
  String navTurnRightOn(String street);

  /// No description provided for @navLeftPlain.
  ///
  /// In es, this message translates to:
  /// **'Gira a la izquierda'**
  String get navLeftPlain;

  /// No description provided for @navRightPlain.
  ///
  /// In es, this message translates to:
  /// **'Gira a la derecha'**
  String get navRightPlain;

  /// No description provided for @navStraightPlain.
  ///
  /// In es, this message translates to:
  /// **'Sigue recto'**
  String get navStraightPlain;

  /// No description provided for @navNextLeftPlain.
  ///
  /// In es, this message translates to:
  /// **'Luego a la izquierda'**
  String get navNextLeftPlain;

  /// No description provided for @navNextRightPlain.
  ///
  /// In es, this message translates to:
  /// **'Luego a la derecha'**
  String get navNextRightPlain;

  /// No description provided for @navNextStraightPlain.
  ///
  /// In es, this message translates to:
  /// **'Luego sigue recto'**
  String get navNextStraightPlain;

  /// No description provided for @navNextLeft.
  ///
  /// In es, this message translates to:
  /// **'Luego a la izquierda en'**
  String get navNextLeft;

  /// No description provided for @navNextRight.
  ///
  /// In es, this message translates to:
  /// **'Luego a la derecha en'**
  String get navNextRight;

  /// No description provided for @navNextStraight.
  ///
  /// In es, this message translates to:
  /// **'Luego sigue recto por'**
  String get navNextStraight;

  /// No description provided for @navNextDestination.
  ///
  /// In es, this message translates to:
  /// **'Luego llegas a'**
  String get navNextDestination;

  /// No description provided for @navEtaLine.
  ///
  /// In es, this message translates to:
  /// **'{distance} · llegada {time}'**
  String navEtaLine(String distance, String time);

  /// No description provided for @navExitTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir de la navegación?'**
  String get navExitTitle;

  /// No description provided for @navExitBody.
  ///
  /// In es, this message translates to:
  /// **'Dejarás de recibir indicaciones hacia el grifo.'**
  String get navExitBody;

  /// No description provided for @navExitKeep.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get navExitKeep;

  /// No description provided for @navExitConfirm.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get navExitConfirm;

  /// No description provided for @navSpeedLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite {n} km/h'**
  String navSpeedLimit(int n);

  /// No description provided for @navDestinationOpen.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle del grifo'**
  String get navDestinationOpen;

  /// No description provided for @arrivalBannerEyebrow.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a tu grifo'**
  String get arrivalBannerEyebrow;

  /// No description provided for @arrivalBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Entra a la isla {island}'**
  String arrivalBannerTitle(String island);

  /// No description provided for @arrivalBannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Surtidor {pump} · a tu {side}'**
  String arrivalBannerSubtitle(String pump, String side);

  /// No description provided for @arrivalSideRight.
  ///
  /// In es, this message translates to:
  /// **'derecha'**
  String get arrivalSideRight;

  /// No description provided for @arrivalSideLeft.
  ///
  /// In es, this message translates to:
  /// **'izquierda'**
  String get arrivalSideLeft;

  /// No description provided for @arrivalChip.
  ///
  /// In es, this message translates to:
  /// **'Llegaste'**
  String get arrivalChip;

  /// No description provided for @arrivalStatDistance.
  ///
  /// In es, this message translates to:
  /// **'Recorrido'**
  String get arrivalStatDistance;

  /// No description provided for @arrivalStatTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get arrivalStatTime;

  /// No description provided for @arrivalStatArrival.
  ///
  /// In es, this message translates to:
  /// **'Llegada'**
  String get arrivalStatArrival;

  /// No description provided for @arrivalPumpShort.
  ///
  /// In es, this message translates to:
  /// **'SURT.'**
  String get arrivalPumpShort;

  /// No description provided for @arrivalPumpTitle.
  ///
  /// In es, this message translates to:
  /// **'Isla {island} · {fuels}'**
  String arrivalPumpTitle(String island, String fuels);

  /// No description provided for @arrivalFuelsBoth.
  ///
  /// In es, this message translates to:
  /// **'GNV y gasolina'**
  String get arrivalFuelsBoth;

  /// No description provided for @arrivalPumpFree.
  ///
  /// In es, this message translates to:
  /// **'Libre ahora'**
  String get arrivalPumpFree;

  /// No description provided for @arrivalPumpBusy.
  ///
  /// In es, this message translates to:
  /// **'Ocupado · te toca pronto'**
  String get arrivalPumpBusy;

  /// No description provided for @arrivalSlide.
  ///
  /// In es, this message translates to:
  /// **'Desliza para empezar la carga'**
  String get arrivalSlide;

  /// No description provided for @arrivalExit.
  ///
  /// In es, this message translates to:
  /// **'Salir de la navegación'**
  String get arrivalExit;

  /// No description provided for @navPumpChip.
  ///
  /// In es, this message translates to:
  /// **'Surtidor {pump}'**
  String navPumpChip(String pump);

  /// No description provided for @navIsleChip.
  ///
  /// In es, this message translates to:
  /// **'Isla {isle}'**
  String navIsleChip(String isle);

  /// No description provided for @navDistanceChip.
  ///
  /// In es, this message translates to:
  /// **'{distance} · {minutes} min'**
  String navDistanceChip(String distance, int minutes);

  /// No description provided for @navExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get navExit;

  /// No description provided for @navView2d.
  ///
  /// In es, this message translates to:
  /// **'2D'**
  String get navView2d;

  /// No description provided for @navView3d.
  ///
  /// In es, this message translates to:
  /// **'3D'**
  String get navView3d;

  /// No description provided for @navRecenter.
  ///
  /// In es, this message translates to:
  /// **'Recentrar'**
  String get navRecenter;

  /// No description provided for @navSpeedUnit.
  ///
  /// In es, this message translates to:
  /// **'km/h'**
  String get navSpeedUnit;

  /// No description provided for @toastNear3d.
  ///
  /// In es, this message translates to:
  /// **'Estás cerca: vista 3D activada.'**
  String get toastNear3d;

  /// No description provided for @streetCanaval.
  ///
  /// In es, this message translates to:
  /// **'Av. Canaval y Moreyra'**
  String get streetCanaval;

  /// No description provided for @streetJavierPrado.
  ///
  /// In es, this message translates to:
  /// **'Av. Javier Prado'**
  String get streetJavierPrado;

  /// No description provided for @streetPetitThouars.
  ///
  /// In es, this message translates to:
  /// **'Av. Petit Thouars'**
  String get streetPetitThouars;

  /// No description provided for @streetArequipa.
  ///
  /// In es, this message translates to:
  /// **'Av. Arequipa'**
  String get streetArequipa;

  /// No description provided for @streetAmericaSur.
  ///
  /// In es, this message translates to:
  /// **'Calle Los Cedros'**
  String get streetAmericaSur;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppL10nEs();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
