import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nfc_spool/core/utils/atomic_file.dart';

void main() {
  test('atomic writer replaces the target and removes temp files', () async {
    final dir = await Directory.systemTemp.createTemp('nfc_spool_atomic_');
    addTearDown(() => dir.delete(recursive: true));
    final target = File('${dir.path}/records.json');

    await target.writeAsString('old');
    await AtomicFileWriter.writeString(target, 'new');

    expect(await target.readAsString(), 'new');
    expect(await File('${target.path}.tmp').exists(), isFalse);
    expect(await File('${target.path}.bak').exists(), isFalse);
  });

  test('recover restores a backup when the target is missing', () async {
    final dir = await Directory.systemTemp.createTemp('nfc_spool_recover_');
    addTearDown(() => dir.delete(recursive: true));
    final target = File('${dir.path}/records.json');
    final backup = File('${target.path}.bak');
    final temp = File('${target.path}.tmp');

    await backup.writeAsString('backup');
    await temp.writeAsString('unfinished');

    await AtomicFileWriter.recover(target);

    expect(await target.readAsString(), 'backup');
    expect(await backup.exists(), isFalse);
    expect(await temp.exists(), isFalse);
  });

  test('recover removes a stale temp file', () async {
    final dir = await Directory.systemTemp.createTemp('nfc_spool_temp_');
    addTearDown(() => dir.delete(recursive: true));
    final target = File('${dir.path}/records.json');
    final temp = File('${target.path}.tmp');

    await target.writeAsString('current');
    await temp.writeAsString('unfinished');

    await AtomicFileWriter.recover(target);

    expect(await target.readAsString(), 'current');
    expect(await temp.exists(), isFalse);
  });
}
