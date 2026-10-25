# NFC/Spool

**[Русская версия](README.md)**

<p align="center">
  <img src="logo/gen02.png" alt="NFC/Spool" width="220">
</p>

Android app for reading and writing filament RFID tags with the phone's built-in NFC. No external RFID reader is required.

Supported: QIDI, OpenSpool, Snapmaker U1, saved tags, and `.bin` import/export.

## Features

- **QIDI**
  - QIDI Plus 4 / Max 4 and QIDI Q2 models.
  - MIFARE Classic 1K, block 4, key A `FFFFFFFFFFFF`.
  - Built-in material, color, and manufacturer lists.
  - QIDI CFG import for a custom material list.
- **OpenSpool**
  - NTAG215/216 NDEF JSON read and write.
  - **OpenSpool Standard** and **Snapmaker U1** profiles.
  - Basic / Standard / All (U1) data tiers, material presets, and color selection.
  - U1 fields: subtype, alpha, bed temperatures, weight, diameter, extra colors.
- **Saved tags**
  - Explicit **Save to data** button.
  - Automatic names, rename, and delete.
  - Rewrite a tag from a saved record.
  - `.bin` export and import with type detection by size.
- **Snapmaker U1**
  - Host/port configuration and HTTP connectivity check.
  - ToolHead status.
  - Send U1 OpenSpool data over Wi-Fi — **without NFC**.
- **Interface**
  - Russian and English.
  - NFC availability check and tag handling hints.
  - Last tab and selected tag options are remembered.

## Requirements

- Android phone with NFC.
- QIDI: **MIFARE Classic 1K**.
- OpenSpool / Snapmaker U1: **NTAG215** or **NTAG216**. NTAG213 is not supported.
- For U1 sending: Snapmaker U1 on the same Wi-Fi network, HTTP port `7125` by default.

## Usage

1. Open the **NFC** tab and make sure NFC is enabled and available.
2. Open the **Tag** tab and choose **QIDI**, **OpenSpool**, or **Snapmaker U1**.
3. Tap **Read tag**, or fill in the fields and tap **Write tag**.
4. Hold the tag against the back of the phone near the camera until the operation finishes.
5. To keep the data, tap **Save to data**.
6. The **Data** tab contains saved tags. You can rewrite, rename, delete, and export `.bin`.
7. Use **Import .bin** in the Data tab. Supported sizes: QIDI 1024 bytes, NTAG215 540 bytes, NTAG216 924 bytes.
8. For U1, open **Settings → Snapmaker U1**, set host/port, save, and tap **Check**.

Saving, saved tags, `.bin` import/export, and U1 sending work without tapping a tag.

## Formats

### QIDI

- Tag: MIFARE Classic 1K.
- Data: block 4, 16 bytes.
- Bytes: `[material_id, color_id, manufacturer_id, 0, ... 0]`.
- `.bin` dump: 1024 bytes, data at offset `4 × 16 = 64`.
- UID and trailer blocks are generated automatically when absent.

### OpenSpool

- Tags: NTAG215 (135 pages, 504 bytes) or NTAG216 (231 pages, 888 bytes).
- CC: `E1 10 3E 00` for NTAG215, `E1 10 6D 00` for NTAG216.
- NDEF record with MIME `application/json`.
- JSON contains `protocol: "openspool"`, `version: "1.0"`, material, and color; U1 adds extended fields.
- User data: pages 4–129 (NTAG215) or 4–225 (NTAG216).
- `.bin` dump: 540 bytes (NTAG215) or 924 bytes (NTAG216).
- NTAG213 is not supported.

### QIDI CFG

Text configuration with `[filaN]` sections and fields such as `filament`, `type`, `min_temp`, `max_temp`, `box_min_temp`, and `box_max_temp`. The imported list replaces the built-in list until CFG is reset.

## Settings

- **Language** — Russian or English.
- **QIDI CFG** — import `.cfg` or reset to built-in lists.
- **Snapmaker U1** — host, port, and ToolHead check.

Manual editing of built-in material/manufacturer lists is not implemented yet.

## Technology

- Flutter / Dart, Material 3.
- `flutter_nfc_kit` — NFC, MIFARE Classic, and raw NTAG commands.
- `provider` — app state.
- `shared_preferences` — settings.
- `path_provider` — local record storage.
- `file_picker` — file import/export.
- `http` — Snapmaker U1 requests.
- `url_launcher` — repository link.

Data is stored locally. Network access is used only for the Snapmaker U1.

## Build

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## Status and limitations

- NFC transport tested on Xiaomi 13T Pro: MIFARE Classic and NTAG read/write.
- Android only.
- No external RFID reader or USB OTG.
- Snapmaker U1 uses HTTP without authentication; phone and printer must be on the same network.
- This is not an official QIDI, Snapmaker, or OpenSpool product.

## Credits

- [MIFARE Classic Tool](https://github.com/ikarus23/MifareClassicTool) — reference for MIFARE Classic via Android NFC.
- [NFC Tools](https://www.wakdev.com/) — reference for raw NTAG commands.
- [BoxRFID-Touch](https://github.com/TinkerBarn/BoxRFID-Touch) — QIDI/OpenSpool logic and formats.
- [OpenSpool](https://github.com/spuder/openspool) — OpenSpool NDEF JSON specification.
- [U1-RFID](https://github.com/DnG-Crafts/U1-RFID) — Snapmaker U1 OpenSpool format reference.

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).
