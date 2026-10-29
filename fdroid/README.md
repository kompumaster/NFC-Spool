# F-Droid

Рецепт для основного репозитория F-Droid:

```text
fdroid/io.github.kompumaster.nfcspool.yml
```

Порядок подачи:

1. Форкнуть `https://gitlab.com/fdroid/fdroiddata`.
2. Скопировать файл в `metadata/io.github.kompumaster.nfcspool.yml`.
3. Прогнать `fdroid lint io.github.kompumaster.nfcspool` и CI fdroiddata.
4. Открыть merge request с меткой `New App`.

Перед подачей:

- добавить скриншоты в `fastlane/metadata/android/*/images/phoneScreenshots/`;
- убедиться, что тег `v0.1.2` есть в GitHub;
- проверить, что `flutter@3.47.7` и `ndk: 28.2.13676358` доступны в сборочном окружении F-Droid.

F-Droid подпишет APK своим ключом. Пользователям, которые ставили APK с GitHub, для перехода на F-Droid потребуется удалить приложение и установить заново.
