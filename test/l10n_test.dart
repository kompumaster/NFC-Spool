import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/app_state.dart';
import 'package:nfc_spool/l10n/app_translations.dart';

void main() {
  test('Configured system countries default to Russian', () {
    for (final country in [
      'RU',
      'UA',
      'BY',
      'KZ',
      'UZ',
      'AZ',
      'GE',
      'MD',
      'LT',
      'LV',
      'KG',
      'TJ',
      'AM',
      'TM',
      'EE',
    ]) {
      expect(
        defaultLanguageForLocale('en_$country'),
        AppLanguage.ru,
        reason: 'country $country',
      );
    }
  });

  test('Non-CIS countries default to English', () {
    expect(defaultLanguageForLocale('en_US'), AppLanguage.en);
    expect(defaultLanguageForLocale('de_DE'), AppLanguage.en);
    expect(defaultLanguageForLocale('ru_DE'), AppLanguage.en);
    expect(defaultLanguageForLocale('zh_CN'), AppLanguage.en);
  });

  test('Language-only locales fall back to language', () {
    expect(defaultLanguageForLocale('ru'), AppLanguage.ru);
    expect(defaultLanguageForLocale('uk'), AppLanguage.ru);
    expect(defaultLanguageForLocale('en'), AppLanguage.en);
  });

  test('English UI labels are translated', () {
    expect(AppTranslations.translate(AppLanguage.en, 'Настройки'), 'Settings');
    expect(
      AppTranslations.translate(AppLanguage.en, 'Прочитать метку'),
      'Read tag',
    );
    expect(AppTranslations.translate(AppLanguage.en, 'Русский'), 'Russian');
    expect(
      AppTranslations.translate(AppLanguage.en, 'NFC доступен'),
      'NFC is available',
    );
    expect(
      AppTranslations.translate(AppLanguage.en, 'Метка Snapmaker U1 прочитана'),
      'Snapmaker U1 tag read',
    );
    expect(
      AppTranslations.translate(
        AppLanguage.en,
        'Метка Snapmaker U1 записана и проверена (NTAG215)',
      ),
      'Snapmaker U1 tag written and verified (NTAG215)',
    );
    expect(
      AppTranslations.translate(AppLanguage.en, 'NFC недоступен.'),
      'NFC is unavailable.',
    );
  });

  test('English keeps Russian for unknown strings', () {
    expect(
      AppTranslations.translate(AppLanguage.en, 'Неизвестная строка'),
      'Неизвестная строка',
    );
  });

  test('English translates dynamic prefixes', () {
    expect(
      AppTranslations.translate(AppLanguage.en, 'Сохранено: PLA'),
      'Saved: PLA',
    );
    expect(
      AppTranslations.translate(
        AppLanguage.en,
        'Списки материалов заблокированы: 32 активных слотов.',
      ),
      'Material lists locked: 32 active slots.',
    );
    expect(
      AppTranslations.translate(AppLanguage.en, 'Создано: 22.10.2026'),
      'Created: 22.10.2026',
    );
    expect(
      AppTranslations.translate(
        AppLanguage.en,
        'CFG: импортированный список · 32 материалов',
      ),
      'CFG: imported list · 32 materials',
    );
    expect(AppTranslations.translate(AppLanguage.en, 'Пусто'), 'Empty');
  });
}
