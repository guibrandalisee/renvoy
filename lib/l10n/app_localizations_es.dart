// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Renvoy';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSubscriptions => 'Suscripciones';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonSubtitle => 'Esta pantalla está en desarrollo.';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get monthlySpend => 'Gasto mensual';

  @override
  String get toggleMonthly => 'Mensual';

  @override
  String get toggleYearly => 'Anual';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones activas',
      one: '1 suscripción activa',
      zero: '0 suscripciones activas',
    );
    return '$_temp0';
  }

  @override
  String get upcomingRenewals => 'Próximas renovaciones';

  @override
  String get spendByGroup => 'Gasto por grupo';

  @override
  String get groupOther => 'Otros';

  @override
  String get noSubgroup => 'Sin subgrupo';

  @override
  String get emptyTitle => 'Aún no hay suscripciones';

  @override
  String get emptySubtitle =>
      'Añade tu primera suscripción para ver tus gastos de un vistazo.';

  @override
  String get addSubscription => 'Añadir suscripción';

  @override
  String get trialChip => 'PRUEBA';

  @override
  String get cycleDay => '/día';

  @override
  String get cycleWeek => '/semana';

  @override
  String get cycleMonth => '/mes';

  @override
  String get cycleYear => '/año';

  @override
  String get newSubscription => 'Nueva suscripción';

  @override
  String get editSubscription => 'Editar suscripción';

  @override
  String get save => 'Guardar';

  @override
  String get name => 'Nombre';

  @override
  String get nameHint => 'Netflix, Spotify, gimnasio...';

  @override
  String get price => 'Precio';

  @override
  String get currency => 'Moneda';

  @override
  String get billingCycle => 'Ciclo de facturación';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get quarterly => 'Trimestral';

  @override
  String get semiAnnual => 'Semestral';

  @override
  String get yearly => 'Anual';

  @override
  String get custom => 'Personalizado';

  @override
  String get every => 'Cada';

  @override
  String get days => 'días';

  @override
  String get weeks => 'semanas';

  @override
  String get months => 'meses';

  @override
  String get years => 'años';

  @override
  String get firstBillDate => 'Primer cobro';

  @override
  String get subscriptionStartDate => 'Inicio de la suscripción';

  @override
  String get freeTrial => 'Prueba gratuita';

  @override
  String get trialEnds => 'Fin de la prueba';

  @override
  String get trialEndAndFirstCharge => 'Fin de la prueba · Primer cobro';

  @override
  String trialBillingExplanation(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prueba gratuita de $count días',
      one: 'Prueba gratuita de 1 día',
    );
    return '$_temp0. No se cobra nada hoy. La facturación comienza el $date y las próximas renovaciones siguen esta fecha.';
  }

  @override
  String get group => 'Grupo';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get reminderDefault => 'Predeterminado (3 días, el mismo día)';

  @override
  String get reminderUseDefaults => 'Usar valores predeterminados';

  @override
  String get reminderSameDay => 'El mismo día';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String reminderRuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas',
      one: '1 regla',
      zero: 'Sin recordatorios',
    );
    return '$_temp0';
  }

  @override
  String get reminderNoRules => 'Sin recordatorios';

  @override
  String get notifRenewalTitle => 'Próxima renovación';

  @override
  String get notifChannelName => 'Recordatorios de renovación';

  @override
  String notifRenewalBody(String name, String when, String price) {
    return '$name se renueva $when — $price';
  }

  @override
  String get notifTrialTitle => 'La prueba está por terminar';

  @override
  String notifTrialBody(String name, String when) {
    return 'La prueba de $name termina $when';
  }

  @override
  String notifInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'dentro de $_temp0';
  }

  @override
  String get none => 'Ninguno';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get paymentMethodHint => 'Tarjeta de crédito Nubank...';

  @override
  String get notes => 'Notas';

  @override
  String get url => 'URL';

  @override
  String get urlHint => 'https://...';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar suscripciones';

  @override
  String get all => 'Todas';

  @override
  String get active => 'Activas';

  @override
  String get paused => 'Pausadas';

  @override
  String get canceled => 'Canceladas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortNextRenewal => 'Próxima renovación';

  @override
  String get sortPrice => 'Precio';

  @override
  String get sortName => 'Nombre';

  @override
  String get noResults => 'No se encontró nada';

  @override
  String get noResultsSubtitle => 'Prueba con otra búsqueda o filtro.';

  @override
  String get discardChangesTitle => '¿Descartar los cambios?';

  @override
  String get discardChangesMessage => 'Tus cambios se perderán.';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get noGroup => 'Sin grupo';

  @override
  String approxPerMonth(String amount) {
    return '≈ $amount /mes';
  }

  @override
  String get pausedNotCounted => 'Pausada — no se incluye en los totales';

  @override
  String trialEndsDate(String date) {
    return 'La prueba termina el $date';
  }

  @override
  String get nextRenewal => 'Próxima renovación';

  @override
  String get firstBill => 'Primer cobro';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get priceHistory => 'Historial de precios';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicated => 'Duplicada';

  @override
  String get cancelSubscription => 'Cancelar suscripción';

  @override
  String get cancelSubscriptionMessage =>
      'Conserva el historial y deja de incluirla en los totales.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteSubscriptionMessage => '¿Eliminar esta suscripción?';

  @override
  String get deleted => 'Eliminada';

  @override
  String get undo => 'DESHACER';

  @override
  String get keep => 'Conservar';

  @override
  String get thisMonth => 'Este mes';

  @override
  String renewalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cobros',
      one: '1 cobro',
      zero: '0 cobros',
    );
    return '$_temp0';
  }

  @override
  String renewalsOn(String date) {
    return 'Cobros el $date';
  }

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupsEmpty => 'Aún no hay grupos';

  @override
  String get groupsEmptySubtitle =>
      'Agrupa suscripciones para ver los gastos por categoría.';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get icon => 'Icono';

  @override
  String get color => 'Color';

  @override
  String get parentGroup => 'Grupo superior';

  @override
  String get noneTopLevel => 'Ninguno (nivel superior)';

  @override
  String groupSummary(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
      zero: '0 suscripciones',
    );
    return '$_temp0 · $amount /mes';
  }

  @override
  String get deleteGroupMessage => '¿Eliminar este grupo?';

  @override
  String get moveContentsUp => 'Mover el contenido al nivel superior';

  @override
  String get ungroupSubscriptions => 'Desagrupar suscripciones';

  @override
  String get deleteEverything => 'Eliminar todo';

  @override
  String get deleteEverythingMessage =>
      '¿Eliminar este grupo y todo su contenido?';

  @override
  String everyCountUnit(int count, String unit) {
    return 'Cada $count $unit';
  }

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsCurrency => 'Moneda';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsSpanish => 'Español';

  @override
  String get settingsPortugueseBrazil => 'Português (Brasil)';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsFirstDay => 'Primer día de la semana';

  @override
  String get settingsMonday => 'Lunes';

  @override
  String get settingsSunday => 'Domingo';

  @override
  String get settingsReminders => 'Recordatorios';

  @override
  String get settingsDefaultReminders => 'Recordatorios predeterminados';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsExportBackup => 'Exportar copia de seguridad';

  @override
  String get settingsImportBackup => 'Importar copia de seguridad';

  @override
  String get settingsExportCsv => 'Exportar CSV';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsVersion => 'Versión';

  @override
  String importConfirm(int subscriptions, int groups) {
    return '¿Importar $subscriptions suscripciones y $groups grupos? Se combinarán con los datos existentes.';
  }

  @override
  String get importError =>
      'No se pudo leer este archivo de copia de seguridad.';

  @override
  String get importSuccess => 'Copia de seguridad importada.';

  @override
  String get exportError => 'No se pudo exportar este archivo.';

  @override
  String get relativeToday => 'hoy';

  @override
  String get relativeTomorrow => 'mañana';

  @override
  String get relativeYesterday => 'ayer';

  @override
  String relativeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'dentro de $_temp0';
  }

  @override
  String get catalogPickerTitle => 'Elige un servicio';

  @override
  String get catalogSearchHint => 'Buscar servicios';

  @override
  String get catalogCreateCustom => 'Crear personalizado';

  @override
  String catalogCreateCustomNamed(String name) {
    return 'Crear personalizado: $name';
  }

  @override
  String get catalogUnavailableTitle => 'Catálogo no disponible';

  @override
  String get catalogUnavailableSubtitle =>
      'Comprueba tu conexión e inténtalo de nuevo, o crea una suscripción personalizada.';

  @override
  String get catalogTryAgain => 'Intentar de nuevo';

  @override
  String get catalogEmptyTitle => 'No se encontraron servicios';

  @override
  String get catalogEmptySubtitle =>
      'Prueba con otra búsqueda o crea una suscripción personalizada.';

  @override
  String get homeLoadError => 'No se pudo cargar tu resumen';

  @override
  String get homeLoadErrorSubtitle =>
      'Tus datos siguen seguros en este dispositivo. Intenta cargarlo de nuevo.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'hace $_temp0';
  }
}
