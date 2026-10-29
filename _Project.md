# NFC/Spool

## Цель

Android-приложение для чтения и записи RFID-меток филамента встроенным NFC телефона. Внешний RFID-ридер и Bluetooth не используются.

Поддерживаются:

- QIDI: MIFARE Classic 1K, блок 4, ключ A `FFFFFFFFFFFF`;
- OpenSpool: NTAG215/216, NDEF JSON;
- Snapmaker U1: профиль OpenSpool U1;
- сохранённые метки;
- импорт и экспорт `.bin`;
- отправка данных на Snapmaker U1 по Wi-Fi;
- русский и английский интерфейс.

## Платформа

- Только Android.
- Основной тестовый телефон: Xiaomi 13T Pro, arm64-v8a.
- Package: `io.github.kompumaster.nfcspool`.
- Отображаемое имя: `NFC/Spool`.
- Версия: `0.1.2+3`.

## Репозиторий

- GitHub: `https://github.com/kompumaster/NFC-Spool`
- Ветка: `main`.
- Лицензия: GPL-3.0.
- Contributors: только `kompumaster`.

## Ключевые решения

- Код Chameleon и BLE полностью удалён.
- NFC работает через `flutter_nfc_kit 3.7.0`.
- QIDI и OpenSpool используют разные NFC-транспорты внутри общего интерфейса.
- Все NFC-операции сериализованы через `NfcService.runExclusive`.
- OpenSpool/U1 профиль определяется по данным метки или `.bin`.
- `records.json` пишется атомарно.
- Snapmaker имеет общий статус `unknown/checking/available/unavailable`; кнопки U1 блокируются, пока связь не проверена.
- Версия в настройках берётся из `package_info_plus`.
- Release подписывается отдельным ключом `nfc-spool`. Старый ключ Chameleon удалён из проекта.

## Важные ограничения

- Snapmaker U1 работает по HTTP без авторизации; телефон и принтер должны быть в одной сети.
- Официальные метки Snapmaker с RSA не поддерживаются.
- NTAG213 не поддерживается.
- QIDI MIFARE Classic поддержан на проверенном телефоне; на других устройствах возможны ограничения NFC-чипа.
- Секреты подписи находятся только локально в `android/key.properties` и `android/keys/`; в Git их быть не должно.
