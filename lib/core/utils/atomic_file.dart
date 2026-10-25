import 'dart:io';

/// Writes small text files by replacing the target atomically where the
/// platform supports it. On Windows, where rename over an existing file is
/// not reliable, the old file is moved to a backup first.
class AtomicFileWriter {
  static Future<void> writeString(File target, String contents) async {
    final temp = File('${target.path}.tmp');
    final backup = File('${target.path}.bak');

    try {
      await temp.parent.create(recursive: true);
      await temp.writeAsString(contents, flush: true);

      if (await target.exists()) {
        try {
          await temp.rename(target.path);
          return;
        } on FileSystemException {
          // Windows does not reliably replace an existing file with rename.
          if (await backup.exists()) {
            try {
              await backup.delete();
            } catch (_) {
              // A stale backup must not block the replacement.
            }
          }
          await target.rename(backup.path);
          try {
            await temp.rename(target.path);
            if (await backup.exists()) {
              await backup.delete();
            }
          } catch (_) {
            if (await backup.exists() && !await target.exists()) {
              await backup.rename(target.path);
            }
            rethrow;
          }
          return;
        }
      }

      await temp.rename(target.path);
    } finally {
      if (await temp.exists()) {
        try {
          await temp.delete();
        } catch (_) {
          // Best effort cleanup.
        }
      }
    }
  }

  /// Removes an unfinished temp file and restores a backup if the main file
  /// disappeared during a previous replacement.
  static Future<void> recover(File target) async {
    final temp = File('${target.path}.tmp');
    final backup = File('${target.path}.bak');

    if (await temp.exists()) {
      try {
        await temp.delete();
      } catch (_) {
        // Best effort cleanup.
      }
    }
    if (!await target.exists() && await backup.exists()) {
      await backup.rename(target.path);
    }
  }
}
