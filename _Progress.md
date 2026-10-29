# Прогресс

Обновлено: 2026-10-29.

## Состояние

- Приложение собрано, установлено на Xiaomi 13T Pro, пользователь подтвердил чтение и запись QIDI и OpenSpool.
- `main` содержит релизный код и последующие коммиты с исправлениями и документацией.
- Тег `v0.1.1` и GitHub release указывают на релизный коммит.
- APK в release обновлены.
- На телефоне установлена arm64-v8a версия `0.1.1`, versionCode `2002`.
- `flutter analyze` проходит без ошибок.
- Тесты проходят через `_tools\run_tests.bat`: 69 тестов, по файлам.

## Что уже сделано

### Миграция с AndroRFID-Chameleon

- Удалены BLE, Chameleon, `flutter_blue_plus`, `permission_handler`, `logger`.
- Удалены Bluetooth-разрешения.
- Добавлены NFC-разрешение и `flutter_nfc_kit`.
- Новый package: `com.nfcspool.app`.
- Новый репозиторий и release.

### NFC

- Добавлен `NfcTagTransport`.
- Добавлен `FlutterNfcTagTransport` для NTAG и MIFARE Classic.
- QIDI переведён на Android `MifareClassic`.
- OpenSpool переведён на raw-команды NTAG.
- Добавлена глобальная блокировка NFC-операций.
- Исправлено определение OpenSpool/U1 профиля.
- Исправлен сброс результата перед новым чтением.
- Добавлен отдельный статус ошибки проверки NFC.

### Данные

- `records.json` пишется атомарно через временный файл.
- Добавлено восстановление `.bak` и очистка `.tmp`.
- `.bin` QIDI и OpenSpool сохранены.
- Профиль OpenSpool при импорте `.bin` определяется по содержимому.

### Snapmaker

- Добавлен общий `SnapmakerStatusService`.
- Кнопки отправки U1 блокируются, пока Snapmaker не проверен.
- Ошибки Snapmaker сокращены и не содержат тело HTTP-ответа.
- Добавлена повторная проверка в диалоге.
- HTTP-клиент закрывается после использования.
- Проверка в настройках обновляет общий статус.

### UI и локализация

- Snapmaker сообщения: `OpenSpool-метка прочитана`, `Snapmaker-метка прочитана`.
- Кнопки результата U1 выровнены по левому краю.
- Переведены `Empty/Loaded`, tooltip NFC.
- Версия в настройках берётся из `package_info_plus`.
- Текст release на GitHub исправлен на UTF-8.

### Мелкие исправления

- Сообщение после записи U1 в карточке сохранённой метки теперь зависит от профиля.
- Удалены 13 неиспользуемых строк перевода.
- В заметках убрана устаревшая привязка текущего `main` к `f63a05d`.

### Иконка

- Добавлен adaptive icon для Android 8+: `mipmap-anydpi-v26/ic_launcher.xml`, белый фон и foreground 108/162/216/324/432.
- Содержимое логотипа вписано в safe zone.

### Тесты

- Причина нестабильности: `flutter_tester.exe` случайно падает с `0xc0000005`; в системе установлен Kaspersky. Код тестов при этом не менялся.
- Добавлен `_tools\run_tests.bat`: запускает файлы по одному и повторяет только сбой загрузки движка.
- Добавлен CI `.github/workflows/ci.yml` для Ubuntu и Windows.

### Проверка сборки

- Чистый клон собирается: `flutter pub get` и `flutter build apk --release`.
- Flutter сам восстанавливает `gradlew`, `gradlew.bat` и `gradle-wrapper.jar`; `gradlew --version` показывает Gradle 9.3.1.
- В APK есть `mipmap/ic_launcher` с `anydpi-v26` и `mipmap/ic_launcher_foreground` для всех плотностей.
- Тесты в чистом клоне проходят через `_tools\run_tests.bat`.
- Без `android/key.properties` release APK подписывается debug-ключом, как задумано в `build.gradle.kts`.

### Релиз 0.1.1

- Adaptive icon для Android 8+.
- Исправлено сообщение после записи U1.
- Удалены неиспользуемые переводы.
- Стабильный прогон тестов по файлам и CI.
- Подготовлены universal и split APK; установлена arm64-v8a `0.1.1`, versionCode `2002`.

### Подпись

- Старый ключ `RFID Chameleon` удалён из `NFC_Spool`.
- Создан новый ключ:

```text
alias: nfc-spool
Owner: CN=kompumaster, O=NFC/Spool
```

- Ключ и пароль лежат только локально, не в Git.
- После смены подписи приложение переустанавливалось.

## Известные особенности

- Полный `flutter test` на Windows нестабилен из-за случайного падения `flutter_tester.exe` (`0xc0000005`). Использовать `_tools\run_tests.bat`; CI запускает тесты по файлам.
- `logo_src/gen02.psd` может быть новее опубликованного `logo/gen02.png`; перед изменением логотипа проверять экспорт PNG.
- Локальные `release/` и `logo_src/` игнорируются Git.
