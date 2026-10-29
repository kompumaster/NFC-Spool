# Todo

## Ближайшее

- [ ] Проверить на телефоне локализацию Snapmaker и версию `0.1.1` в настройках.
- [ ] Мёртвый код - пока не трогать (решение пользователя):
  - `NfcTagInfo.rawType` и `mifareType`;
  - `SnapmakerToolHead.label`;
  - legacy `OpenSpoolBinCodec.dumpSize`.
- [x] Добавить adaptive icon для Android 8+.
- [ ] `usesCleartextTraffic`: оставить глобально, пока не принято другое решение. Статический `network_security_config` не покрывает произвольный IP принтера; при необходимости добавить проверку приватного IP в `SnapmakerService`.
- [x] Проверить сборку из чистого клона, в том числе Gradle wrapper.

## Тесты

- [x] Стабильный прогон на Windows: `_tools\run_tests.bat` запускает файлы по одному и повторяет только сбой загрузки движка.
- [x] Добавить CI: `.github/workflows/ci.yml`, Ubuntu и Windows.
- [ ] Добавить тесты UI для импорта/экспорта `.bin`.
- [ ] Добавить тесты сценариев Snapmaker с ошибками сети и HTTP.

## Релиз

- [x] Решить, когда поднимать версию до `0.1.1+2`.
- [x] При выпуске новой версии обновить тег и release.
- [ ] Хранить резервную копию `android/keys/nfc-spool-release.jks` и пароля.

## Не делать без отдельного решения

- Не возвращать Chameleon и BLE.
- Не менять формат QIDI/OpenSpool без проверки совместимости.
- Не коммитить `android/key.properties`, `android/keys/`, `logo_src/`, `release/`.
