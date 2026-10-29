# Todo

## Ближайшее

- [ ] Проверить на телефоне локализацию Snapmaker и версию `0.1.0` в настройках.
- [ ] Убрать мёртвый код:
  - `NfcTagInfo.rawType` и `mifareType`;
  - `SnapmakerToolHead.label`;
  - legacy `OpenSpoolBinCodec.dumpSize`.
- [ ] Добавить adaptive icon для Android 8+.
- [ ] Ограничить `android:usesCleartextTraffic` только Snapmaker через `network_security_config`.
- [ ] Проверить сборку из чистого клона, в том числе Gradle wrapper.

## Тесты

- [ ] Добавить тесты UI для импорта/экспорта `.bin`.
- [ ] Добавить тесты сценариев Snapmaker с ошибками сети и HTTP.
- [ ] Проверить стабильность полного `flutter test` на Windows и CI.

## Релиз

- [ ] Решить, когда поднимать версию до `0.1.1+2`.
- [ ] При выпуске новой версии обновить тег и release.
- [ ] Хранить резервную копию `android/keys/nfc-spool-release.jks` и пароля.

## Не делать без отдельного решения

- Не возвращать Chameleon и BLE.
- Не менять формат QIDI/OpenSpool без проверки совместимости.
- Не коммитить `android/key.properties`, `android/keys/`, `logo_src/`, `release/`.
