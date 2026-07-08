import 'app_localizations.dart';

extension AppLocalizationsFallbacks on AppLocalizations {
  bool get _isPt => localeName.startsWith('pt');

  String get reminders => _isPt ? 'Lembretes' : 'Reminders';
  String get reminderDefault =>
      _isPt ? 'Padrão (3 dias, no dia)' : 'Default (3 days, same day)';
  String get reminderUseDefaults => _isPt ? 'Usar padrões' : 'Use defaults';
  String get reminderSameDay => _isPt ? 'No dia' : 'Same day';
  String reminderDaysBefore(int count) {
    if (_isPt) {
      return count == 1 ? '1 dia' : '$count dias';
    }
    return count == 1 ? '1 day' : '$count days';
  }

  String reminderRuleCount(int count) {
    if (_isPt) {
      return switch (count) {
        0 => 'Sem lembretes',
        1 => '1 regra',
        _ => '$count regras',
      };
    }
    return switch (count) {
      0 => 'No reminders',
      1 => '1 rule',
      _ => '$count rules',
    };
  }

  String get reminderNoRules => _isPt ? 'Sem lembretes' : 'No reminders';
  String get notifRenewalTitle =>
      _isPt ? 'Renovação próxima' : 'Upcoming renewal';
  String notifRenewalBody(String name, String when, String price) {
    return _isPt
        ? '$name renova $when — $price'
        : '$name renews $when — $price';
  }

  String get notifTrialTitle => _isPt ? 'Teste acabando' : 'Trial ending';
  String notifTrialBody(String name, String when) {
    return _isPt ? 'O teste de $name acaba $when' : '$name trial ends $when';
  }

  String notifInDays(int count) {
    if (_isPt) {
      return count == 1 ? 'em 1 dia' : 'em $count dias';
    }
    return count == 1 ? 'in 1 day' : 'in $count days';
  }

  String get settingsGeneral => _isPt ? 'Geral' : 'General';
  String get settingsCurrency => _isPt ? 'Moeda' : 'Currency';
  String get settingsLanguage => _isPt ? 'Idioma' : 'Language';
  String get settingsSystem => _isPt ? 'Sistema' : 'System';
  String get settingsEnglish => 'English';
  String get settingsPortugueseBrazil => 'Português (Brasil)';
  String get settingsTheme => _isPt ? 'Tema' : 'Theme';
  String get settingsLight => _isPt ? 'Claro' : 'Light';
  String get settingsDark => _isPt ? 'Escuro' : 'Dark';
  String get settingsFirstDay =>
      _isPt ? 'Primeiro dia da semana' : 'First day of week';
  String get settingsMonday => _isPt ? 'Segunda-feira' : 'Monday';
  String get settingsSunday => _isPt ? 'Domingo' : 'Sunday';
  String get settingsReminders => _isPt ? 'Lembretes' : 'Reminders';
  String get settingsDefaultReminders =>
      _isPt ? 'Lembretes padrão' : 'Default reminders';
  String get settingsData => _isPt ? 'Dados' : 'Data';
  String get settingsExportBackup =>
      _isPt ? 'Exportar backup' : 'Export backup';
  String get settingsImportBackup =>
      _isPt ? 'Importar backup' : 'Import backup';
  String get settingsExportCsv => _isPt ? 'Exportar CSV' : 'Export CSV';
  String get settingsAbout => _isPt ? 'Sobre' : 'About';
  String get settingsVersion => _isPt ? 'Versão' : 'Version';

  String importConfirm(int subscriptions, int groups) {
    return _isPt
        ? 'Importar $subscriptions assinaturas, $groups grupos? Isso mescla com os dados existentes.'
        : 'Import $subscriptions subscriptions, $groups groups? This merges with existing data.';
  }

  String get importError => _isPt
      ? 'Não foi possível ler este arquivo de backup.'
      : 'Could not read this backup file.';
  String get importSuccess => _isPt ? 'Backup importado.' : 'Backup imported.';
  String get exportError => _isPt
      ? 'Não foi possível exportar este arquivo.'
      : 'Could not export this file.';

  String get relativeToday => _isPt ? 'hoje' : 'today';
  String get relativeTomorrow => _isPt ? 'amanhã' : 'tomorrow';
  String get relativeYesterday => _isPt ? 'ontem' : 'yesterday';
  String relativeInDays(int count) {
    if (_isPt) {
      return count == 1 ? 'em 1 dia' : 'em $count dias';
    }
    return count == 1 ? 'in 1 day' : 'in $count days';
  }

  String relativeDaysAgo(int count) {
    if (_isPt) {
      return count == 1 ? 'há 1 dia' : 'há $count dias';
    }
    return count == 1 ? '1 day ago' : '$count days ago';
  }
}
