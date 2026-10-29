import '../../app_state.dart';

class AppTranslations {
  static String translate(AppLanguage language, String source) {
    if (language == AppLanguage.ru) {
      return source;
    }
    final exact = _en[source];
    if (exact != null) {
      return exact;
    }

    for (final entry in _prefixes.entries) {
      if (source.startsWith(entry.key)) {
        return entry.value +
            translate(language, source.substring(entry.key.length));
      }
    }

    var result = source;
    final entries = _en.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      if (result.contains(entry.key)) {
        result = result.replaceAll(entry.key, entry.value);
      }
    }
    return result;
  }

  static const Map<String, String> _prefixes = {
    'Сохранено: ': 'Saved: ',
    'Импортировано: ': 'Imported: ',
    'CFG импортирован: ': 'CFG imported: ',
    'Создано: ': 'Created: ',
    'QIDI CFG: ': 'QIDI CFG: ',
    'Списки материалов заблокированы: ': 'Material lists locked: ',
    'Не удалось импортировать .bin: ': 'Could not import .bin: ',
    'Неподдерживаемый размер .bin: ': 'Unsupported .bin size: ',
    'Не удалось сохранить запись: ': 'Could not save record: ',
    'Не удалось экспортировать .bin: ': 'Could not export .bin: ',
    'Не удалось переименовать: ': 'Could not rename: ',
    'Не удалось импортировать CFG: ': 'Could not import CFG: ',
    'CFG: ': 'CFG: ',
    'Текущий адрес: ': 'Current address: ',
    'При первом запуске: СНГ → русский, остальные → английский.':
        'First launch: CIS → Russian, others → English.',
    'Редактирование списков вручную пока не реализовано. QIDI CFG импортируется выше.': 'Manual list editing is not implemented yet. QIDI CFG is imported above.',
    ' материалов · 24 цвета · 2 производителя.':
        ' materials · 24 colors · 2 manufacturers.',
    ' материалов · 22 производителя.': ' materials · 22 manufacturers.',
    'Метка вернула ': 'Tag returned ',
    'NTAG не вернул страницу ': 'NTAG did not return page ',
    'NTAG не подтвердил запись страницы ':
        'NTAG did not confirm write of page ',
    'NTAG вернул ': 'NTAG returned ',
    'Не удалось открыть ссылку: ': 'Could not open the link: ',
    'NTAG213 не поддерживается. Используйте NTAG215 или NTAG216.':
        'NTAG213 is not supported. Use NTAG215 or NTAG216.',
    'Не удалось определить тип метки. Ожидается NTAG215/216, CC: ':
        'Could not detect the tag type. Expected NTAG215/216, CC: ',
    'OpenSpool-метка записана и проверена (':
        'OpenSpool tag written and verified (',
    'Snapmaker-метка записана и проверена (':
        'Snapmaker tag written and verified (',
    'U1 не вернул filament_detected для ToolHead ':
        'U1 did not return filament_detected for ToolHead ',
  };

  static const Map<String, String> _en = {
    'NFC/Spool': 'NFC/Spool',
    'NFC': 'NFC',
    'Проверить NFC': 'Check NFC',
    'NFC доступен': 'NFC is available',
    'Можно читать и записывать метки.': 'Tags can be read and written.',
    'NFC выключен': 'NFC is off',
    'Включите NFC в настройках Android и нажмите «Проверить».':
        'Turn on NFC in Android settings and tap “Check”.',
    'NFC не поддерживается': 'NFC is not supported',
    'Этот телефон не умеет работать с NFC-метками.':
        'This phone cannot work with NFC tags.',
    'Не удалось проверить NFC': 'Could not check NFC',
    'Нажмите «Проверить», чтобы попробовать снова.':
        'Tap “Check” to try again.',
    'Проверка NFC…': 'Checking NFC…',
    'Определяю доступность NFC на телефоне.':
        'Checking NFC availability on this phone.',
    'Выполняется NFC-операция': 'NFC operation in progress',
    'Держите метку до завершения операции.':
        'Hold the tag until the operation finishes.',
    'Как пользоваться': 'How to use',
    'Откройте вкладку «Метка» и выберите QIDI, OpenSpool или Snapmaker U1.':
        'Open the “Tag” tab and choose QIDI, OpenSpool, or Snapmaker U1.',
    'Нажмите «Прочитать метку» или «Записать метку».':
        'Tap “Read tag” or “Write tag”.',
    'Приложите метку к задней панели телефона рядом с камерой и держите до завершения операции.': 'Hold the tag against the back of the phone near the camera until the operation finishes.',
    'Поддерживаемые метки': 'Supported tags',
    'NTAG215 или NTAG216. NTAG213 не поддерживается.':
        'NTAG215 or NTAG216. NTAG213 is not supported.',
    'Сохранение меток, импорт и экспорт .bin, а также отправка на Snapmaker U1 работают без прикладывания метки.': 'Saving tags, .bin import/export, and sending to Snapmaker U1 work without tapping a tag.',
    'Отправка по Wi-Fi не требует NFC. Телефон и принтер должны быть в одной сети. Используется HTTP.': 'Wi-Fi sending does not require NFC. Phone and printer must be on the same network. HTTP is used.',
    'NFC недоступен — чтение и запись метки выключены.':
        'NFC is unavailable — tag reading and writing are disabled.',
    'NFC недоступен — чтение и запись метки выключены. Сохранение и отправка на U1 работают.': 'NFC is unavailable — tag reading and writing are disabled. Saving and sending to U1 still work.',
    'Приложите QIDI-метку к телефону и нажмите «Прочитать метку».':
        'Place a QIDI tag on the phone and tap “Read tag”.',
    'Приложите NTAG215/216 с OpenSpool-записью к телефону и нажмите «Прочитать метку».': 'Place an NTAG215/216 with an OpenSpool record on the phone and tap “Read tag”.',
    'NFC недоступен.': 'NFC is unavailable.',
    'Уже выполняется другая NFC-операция. Дождитесь завершения.':
        'Another NFC operation is already running. Wait for it to finish.',
    'Это не MIFARE Classic 1K. Приложите QIDI-метку к телефону.':
        'This is not MIFARE Classic 1K. Place a QIDI tag on the phone.',
    'Это не NTAG215/216. Приложите подходящую метку к телефону.':
        'This is not NTAG215/216. Place a suitable tag on the phone.',
    'Не удалось прочитать или записать QIDI-метку. Проверьте, что это MIFARE Classic 1K, и держите метку у телефона. Ошибка: ': 'Could not read or write the QIDI tag. Make sure it is MIFARE Classic 1K and hold the tag against the phone. Error: ',
    'Не удалось прочитать или записать OpenSpool-метку. Проверьте, что это NTAG215/216, и держите метку у телефона. Ошибка: ': 'Could not read or write the OpenSpool tag. Make sure it is NTAG215/216 and hold the tag against the phone. Error: ',
    'NTAG вернул неполную CC-страницу.': 'NTAG returned an incomplete CC page.',
    'NTAG вернул неполный заголовок.': 'NTAG returned an incomplete header.',
    'Не удалось аутентифицировать сектор ': 'Could not authenticate sector ',
    'Не удалось открыть ссылку': 'Could not open the link',
    'Нажмите «Назад» ещё раз для выхода': 'Press Back again to exit',
    'Порт должен быть числом': 'Port must be a number',
    'Метка': 'Tag',
    'Данные': 'Data',
    'Настройки': 'Settings',
    'Читать': 'Read',
    'Записать': 'Write',
    'Чтение QIDI-метки': 'Read QIDI tag',
    'MIFARE Classic 1K, блок 4, ключ A FFFFFFFFFFFF.':
        'MIFARE Classic 1K, block 4, key A FFFFFFFFFFFF.',
    'Прочитать метку': 'Read tag',
    'Читаю…': 'Reading…',
    'Метка прочитана': 'Tag read',
    'Запись QIDI-метки': 'Write QIDI tag',
    'Будут записаны блок 4 и нули в байтах 3–15.':
        'Block 4 will be written; bytes 3–15 will be zeroed.',
    'Модель принтера': 'Printer model',
    'Материал': 'Material',
    'Цвет': 'Color',
    'Цвет (color_hex)': 'Color (color_hex)',
    'Выбор цвета': 'Select color',
    'Свой HEX': 'Custom HEX',
    'Применить': 'Apply',
    'Некорректный HEX': 'Invalid HEX',
    'Производитель': 'Manufacturer',
    'Предпросмотр блока 4': 'Block 4 preview',
    'Записать метку': 'Write tag',
    'Записываю…': 'Writing…',
    'Сохранить в данные': 'Save to data',
    'Новая метка': 'New tag',
    'Прочитано': 'Read result',
    'Блок 4': 'Block 4',
    'Чтение OpenSpool': 'Read OpenSpool',
    'Чтение Snapmaker U1': 'Read Snapmaker U1',
    'NTAG215/216, CC E1 10 3E 00 / E1 10 6D 00, MIME application/json.':
        'NTAG215/216, CC E1 10 3E 00 / E1 10 6D 00, MIME application/json.',
    'OpenSpool-метка прочитана': 'OpenSpool tag read',
    'Snapmaker-метка прочитана': 'Snapmaker tag read',
    'Запись OpenSpool': 'Write OpenSpool',
    'Запись Snapmaker U1': 'Write Snapmaker U1',
    'JSON/NDEF будет записан в пользовательские страницы NTAG215/216.':
        'JSON/NDEF will be written to the NTAG215/216 user pages.',
    'Версия данных': 'Data version',
    'Бренд': 'Brand',
    'Подтип (subtype)': 'Subtype',
    'Нет': 'None',
    'Сопло min, °C': 'Nozzle min, °C',
    'Сопло max, °C': 'Nozzle max, °C',
    'Стол min, °C': 'Bed min, °C',
    'Стол max, °C': 'Bed max, °C',
    'Сопло': 'Nozzle',
    'Стол': 'Bed',
    'Вес': 'Weight',
    'Диаметр': 'Diameter',
    'Доп. цвета': 'Extra colors',
    'Alpha': 'Alpha',
    'Alpha / прозрачность': 'Alpha / transparency',
    'Прозрачность:': 'Transparency:',
    '0% — непрозрачный, 100% — прозрачный': '0% — opaque, 100% — transparent',
    'Вес, г': 'Weight, g',
    'Диаметр, мм': 'Diameter, mm',
    'Доп. цвета через запятую': 'Extra colors, comma separated',
    'JSON для записи': 'JSON to write',
    'OpenSpool-метка записана и проверена':
        'OpenSpool tag written and verified',
    'Отправить на U1': 'Send to U1',
    'Сохранённые метки': 'Saved tags',
    'Импорт .bin': 'Import .bin',
    'Пока нет сохранённых меток': 'No saved tags yet',
    'Прочитайте метку или создайте новую на вкладке «Метка» и нажмите «Сохранить в данные». Также можно импортировать совместимый .bin.': 'Read or create a tag on the “Tag” tab and tap “Save to data”. You can also import a compatible .bin.',
    'Имя записи': 'Record name',
    'Отмена': 'Cancel',
    'Сохранить': 'Save',
    'Удалить запись?': 'Delete record?',
    'Удалить': 'Delete',
    'Переименовать': 'Rename',
    'Записать на метку': 'Write to tag',
    'Экспорт .bin': 'Export .bin',
    'Экспорт .bin (540)': 'Export .bin (540)',
    'Экспорт .bin (924)': 'Export .bin (924)',
    'Snapmaker U1': 'Snapmaker U1',
    'Host / IP': 'Host / IP',
    'Порт': 'Port',
    'Проверить': 'Check',
    'Нажмите «Проверить», чтобы загрузить состояние ToolHead.':
        'Tap “Check” to load ToolHead status.',
    'Связь с U1 установлена': 'U1 connection established',
    'Snapmaker U1 не отвечает. Проверьте, что принтер включён, host/port верны и телефон в той же Wi-Fi сети.': 'Snapmaker U1 is not responding. Make sure the printer is on, host/port are correct, and the phone is on the same Wi-Fi network.',
    'Нет связи со Snapmaker. Проверьте Wi-Fi и host/port.':
        'No connection to Snapmaker. Check Wi-Fi and host/port.',
    'Snapmaker вернул ошибку HTTP ': 'Snapmaker returned HTTP error ',
    'Не удалось связаться со Snapmaker. Проверьте настройки и сеть.':
        'Could not reach Snapmaker. Check the settings and network.',
    'Snapmaker недоступен — проверьте подключение в Настройках.':
        'Snapmaker is unavailable — check the connection in Settings.',
    'Snapmaker не проверен — откройте Настройки → Snapmaker U1 и нажмите «Проверить».': 'Snapmaker is not checked — open Settings → Snapmaker U1 and tap “Check”.',
    'Повторить': 'Retry',
    'Пусто': 'Empty',
    'Загружено': 'Loaded',
    'Отправить': 'Send',
    'Закрыть': 'Close',
    'Отправить на Snapmaker U1': 'Send to Snapmaker U1',
    'В ToolHead уже обнаружен филамент. Перезаписать данные?':
        'Filament is already detected in this ToolHead. Overwrite the data?',
    'Перезаписать': 'Overwrite',
    'Данные отправлены в U1': 'Data sent to U1',
    'Проверьте host/port в Настройках.': 'Check host/port in Settings.',
    'Язык / Language': 'Language',
    'Русский': 'Russian',
    'Списки': 'Lists',
    'QIDI CFG не импортирован': 'QIDI CFG is not imported',
    'Можно импортировать officiall_filas_list.cfg с принтера.':
        'You can import officiall_filas_list.cfg from the printer.',
    'Импорт .cfg': 'Import .cfg',
    'Сбросить': 'Reset',
    'Импорт QIDI .cfg': 'Import QIDI .cfg',
    'CFG сброшен, используются встроенные списки':
        'CFG reset; built-in lists are used',
    'Метка записана и проверена': 'Tag written and verified',
    'QIDI-метка записана и проверена': 'QIDI tag written and verified',
    'Файл сохранён': 'File saved',
    'импортированный список': 'imported list',
    'материалов': 'materials',
    'активных слотов': 'active slots',
    'занят': 'busy',
    'будет удалена.': 'will be deleted.',
    'Проверка после записи OpenSpool не совпала.':
        'OpenSpool write verification failed.',
    'Проверка после записи не совпала.': 'Write verification failed.',
    'Не удалось получить статус U1': 'Could not get U1 status',
    'В ответе U1 нет filament_detect.info':
        'U1 response has no filament_detect.info',
    'ToolHead должен быть от 1 до 4': 'ToolHead must be from 1 to 4',
    'Не удалось проверить датчик филамента': 'Could not read filament sensor',
    'U1 не принял данные': 'U1 rejected the data',
    'U1 вернул некорректный JSON': 'U1 returned invalid JSON',
    'неизвестно': 'unknown',
    'импортирован': 'imported',
    'Сохранить QIDI .bin': 'Save QIDI .bin',
    'Сохранить OpenSpool .bin': 'Save OpenSpool .bin',
    'Неподдерживаемый размер .bin': 'Unsupported .bin size',
    'Ожидается 1024 (QIDI), 540 (NTAG215) или 924 (NTAG216).':
        'Expected 1024 (QIDI), 540 (NTAG215), or 924 (NTAG216).',
    'байт вместо': 'bytes instead of',
    'QIDI': 'QIDI',
    'OpenSpool': 'OpenSpool',
  };
}
