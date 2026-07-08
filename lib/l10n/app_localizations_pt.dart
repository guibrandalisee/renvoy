// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Renvoy';

  @override
  String get navHome => 'Início';

  @override
  String get navSubscriptions => 'Assinaturas';

  @override
  String get navCalendar => 'Calendário';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get comingSoonTitle => 'Em breve';

  @override
  String get comingSoonSubtitle => 'Esta tela está sendo criada.';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get monthlySpend => 'Gasto mensal';

  @override
  String get toggleMonthly => 'Mensal';

  @override
  String get toggleYearly => 'Anual';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assinaturas ativas',
      one: '1 assinatura ativa',
      zero: '0 assinaturas ativas',
    );
    return '$_temp0';
  }

  @override
  String get upcomingRenewals => 'Próximas renovações';

  @override
  String get spendByGroup => 'Gasto por grupo';

  @override
  String get groupOther => 'Outros';

  @override
  String get emptyTitle => 'Nenhuma assinatura ainda';

  @override
  String get emptySubtitle =>
      'Adicione sua primeira assinatura para ver seus gastos num relance.';

  @override
  String get addSubscription => 'Adicionar assinatura';

  @override
  String get trialChip => 'TRIAL';

  @override
  String get cycleDay => '/dia';

  @override
  String get cycleWeek => '/semana';

  @override
  String get cycleMonth => '/mês';

  @override
  String get cycleYear => '/ano';

  @override
  String get newSubscription => 'Nova assinatura';

  @override
  String get editSubscription => 'Editar assinatura';

  @override
  String get save => 'Salvar';

  @override
  String get name => 'Nome';

  @override
  String get nameHint => 'Netflix, Spotify, academia...';

  @override
  String get price => 'Preço';

  @override
  String get currency => 'Moeda';

  @override
  String get billingCycle => 'Ciclo de cobrança';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get quarterly => 'Trimestral';

  @override
  String get semiAnnual => 'Semestral';

  @override
  String get yearly => 'Anual';

  @override
  String get custom => 'Personalizado';

  @override
  String get every => 'A cada';

  @override
  String get days => 'dias';

  @override
  String get weeks => 'semanas';

  @override
  String get months => 'meses';

  @override
  String get years => 'anos';

  @override
  String get firstBillDate => 'Primeira cobrança';

  @override
  String get freeTrial => 'Teste grátis';

  @override
  String get trialEnds => 'Teste termina';

  @override
  String get group => 'Grupo';

  @override
  String get reminders => 'Lembretes';

  @override
  String get reminderDefault => 'Padrão (3 dias, no dia)';

  @override
  String get reminderUseDefaults => 'Usar padrões';

  @override
  String get reminderSameDay => 'No dia';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String reminderRuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regras',
      one: '1 regra',
      zero: 'Sem lembretes',
    );
    return '$_temp0';
  }

  @override
  String get reminderNoRules => 'Sem lembretes';

  @override
  String get notifRenewalTitle => 'Renovação próxima';

  @override
  String notifRenewalBody(String name, String when, String price) {
    return '$name renova $when — $price';
  }

  @override
  String get notifTrialTitle => 'Teste acabando';

  @override
  String notifTrialBody(String name, String when) {
    return 'O teste de $name acaba $when';
  }

  @override
  String notifInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return 'em $_temp0';
  }

  @override
  String get none => 'Nenhum';

  @override
  String get paymentMethod => 'Forma de pagamento';

  @override
  String get paymentMethodHint => 'Cartão de crédito Nubank...';

  @override
  String get notes => 'Notas';

  @override
  String get url => 'URL';

  @override
  String get urlHint => 'https://...';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar assinaturas';

  @override
  String get all => 'Todas';

  @override
  String get active => 'Ativas';

  @override
  String get paused => 'Pausadas';

  @override
  String get canceled => 'Canceladas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortNextRenewal => 'Próxima renovação';

  @override
  String get sortPrice => 'Preço';

  @override
  String get sortName => 'Nome';

  @override
  String get noResults => 'Nada encontrado';

  @override
  String get noResultsSubtitle => 'Tente outra busca ou filtro.';

  @override
  String get discardChangesTitle => 'Descartar alterações?';

  @override
  String get discardChangesMessage => 'Suas alterações serão perdidas.';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get discard => 'Descartar';

  @override
  String get noGroup => 'Sem grupo';

  @override
  String approxPerMonth(String amount) {
    return '≈ $amount /mês';
  }

  @override
  String get pausedNotCounted => 'Pausada — não conta nos totais';

  @override
  String trialEndsDate(String date) {
    return 'Teste termina em $date';
  }

  @override
  String get nextRenewal => 'Próxima renovação';

  @override
  String get firstBill => 'Primeira cobrança';

  @override
  String get manageSubscription => 'Gerenciar assinatura';

  @override
  String get priceHistory => 'Histórico de preços';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Retomar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicated => 'Duplicada';

  @override
  String get cancelSubscription => 'Cancelar assinatura';

  @override
  String get cancelSubscriptionMessage =>
      'Manter histórico e parar de contar nos totais.';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteSubscriptionMessage => 'Excluir esta assinatura?';

  @override
  String get deleted => 'Excluída';

  @override
  String get undo => 'DESFAZER';

  @override
  String get keep => 'Manter';

  @override
  String get thisMonth => 'Este mês';

  @override
  String renewalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count renovações',
      one: '1 renovação',
      zero: '0 renovações',
    );
    return '$_temp0';
  }

  @override
  String renewalsOn(String date) {
    return 'Renovações em $date';
  }

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupsEmpty => 'Nenhum grupo ainda';

  @override
  String get groupsEmptySubtitle =>
      'Agrupe assinaturas para ver gastos por categoria.';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get icon => 'Ícone';

  @override
  String get color => 'Cor';

  @override
  String get parentGroup => 'Grupo pai';

  @override
  String get noneTopLevel => 'Nenhum (nível superior)';

  @override
  String groupSummary(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assinaturas',
      one: '1 assinatura',
      zero: '0 assinaturas',
    );
    return '$_temp0 · $amount /mês';
  }

  @override
  String get deleteGroupMessage => 'Excluir este grupo?';

  @override
  String get moveContentsUp => 'Mover conteúdo para cima';

  @override
  String get ungroupSubscriptions => 'Remover assinaturas do grupo';

  @override
  String get deleteEverything => 'Excluir tudo';

  @override
  String get deleteEverythingMessage =>
      'Excluir este grupo e tudo dentro dele?';

  @override
  String everyCountUnit(int count, String unit) {
    return 'A cada $count $unit';
  }

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsCurrency => 'Moeda';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsPortugueseBrazil => 'Português (Brasil)';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Escuro';

  @override
  String get settingsFirstDay => 'Primeiro dia da semana';

  @override
  String get settingsMonday => 'Segunda-feira';

  @override
  String get settingsSunday => 'Domingo';

  @override
  String get settingsReminders => 'Lembretes';

  @override
  String get settingsDefaultReminders => 'Lembretes padrão';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsExportBackup => 'Exportar backup';

  @override
  String get settingsImportBackup => 'Importar backup';

  @override
  String get settingsExportCsv => 'Exportar CSV';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsVersion => 'Versão';

  @override
  String importConfirm(int subscriptions, int groups) {
    return 'Importar $subscriptions assinaturas, $groups grupos? Isso mescla com os dados existentes.';
  }

  @override
  String get importError => 'Não foi possível ler este arquivo de backup.';

  @override
  String get importSuccess => 'Backup importado.';

  @override
  String get exportError => 'Não foi possível exportar este arquivo.';

  @override
  String get relativeToday => 'hoje';

  @override
  String get relativeTomorrow => 'amanhã';

  @override
  String get relativeYesterday => 'ontem';

  @override
  String relativeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return 'em $_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return 'há $_temp0';
  }
}
