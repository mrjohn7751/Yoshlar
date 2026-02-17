import 'dart:typed_data';
import 'package:excel/excel.dart';

class ExcelParseResult {
  final List<Map<String, dynamic>> rows;
  final List<ExcelParseError> errors;

  ExcelParseResult({required this.rows, required this.errors});
}

class ExcelParseError {
  final int row;
  final String message;

  ExcelParseError({required this.row, required this.message});
}

/// Columns:
/// 0: F.I.Sh → name
/// 1: Telefon → phone
/// 2: Jinsi → gender
/// 3: Tug'ilgan sana → birthDate
/// 4: Tuman → region
/// 5: Manzil → location
/// 6: Ta'lim → status
/// 7: Bandlik → activity
/// 8: Xavf darajasi → riskLevel
ExcelParseResult parseExcelBytes(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);
  final rows = <Map<String, dynamic>>[];
  final errors = <ExcelParseError>[];

  final sheet = excel.tables[excel.tables.keys.first];
  if (sheet == null || sheet.rows.isEmpty) {
    errors.add(ExcelParseError(row: 0, message: "Excel fayl bo'sh"));
    return ExcelParseResult(rows: rows, errors: errors);
  }

  // Skip header row (index 0)
  for (int i = 1; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    final rowNum = i + 1; // 1-indexed for display

    // Skip completely empty rows
    if (row.every((cell) => cell == null || _cellToString(cell) .isEmpty)) {
      continue;
    }

    final name = _getCellString(row, 0);
    if (name.isEmpty) {
      errors.add(ExcelParseError(row: rowNum, message: "Ism bo'sh"));
      continue;
    }

    final gender = _getCellString(row, 2);
    if (gender.isNotEmpty && gender != 'Erkak' && gender != 'Ayol') {
      errors.add(ExcelParseError(
        row: rowNum,
        message: "Jins noto'g'ri: '$gender' (Erkak yoki Ayol bo'lishi kerak)",
      ));
      continue;
    }

    final birthDate = _parseDateCell(row, 3);
    if (birthDate == null) {
      errors.add(ExcelParseError(
        row: rowNum,
        message: "Tug'ilgan sana noto'g'ri yoki bo'sh",
      ));
      continue;
    }

    rows.add({
      'name': name,
      'phone': _getCellString(row, 1),
      'gender': gender.isNotEmpty ? gender : 'Erkak',
      'birthDate': birthDate,
      'region': _getCellString(row, 4),
      'location': _getCellString(row, 5),
      'status': _getCellString(row, 6),
      'activity': _getCellString(row, 7),
      'riskLevel': _getCellString(row, 8),
    });
  }

  return ExcelParseResult(rows: rows, errors: errors);
}

String _getCellString(List<Data?> row, int index) {
  if (index >= row.length || row[index] == null) return '';
  return _cellToString(row[index]!);
}

String _cellToString(Data cell) {
  final value = cell.value;
  if (value == null) return '';
  if (value is TextCellValue) return value.value.toString().trim();
  if (value is IntCellValue) return value.value.toString();
  if (value is DoubleCellValue) return value.value.toString();
  if (value is DateCellValue) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
  if (value is DateTimeCellValue) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
  return value.toString().trim();
}

String? _parseDateCell(List<Data?> row, int index) {
  if (index >= row.length || row[index] == null) return null;
  final cell = row[index]!;
  final value = cell.value;

  if (value == null) return null;

  // Direct date types from Excel
  if (value is DateCellValue) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
  if (value is DateTimeCellValue) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  // Numeric serial date (Excel days since 1899-12-30)
  if (value is IntCellValue || value is DoubleCellValue) {
    final num serial;
    if (value is IntCellValue) {
      serial = value.value;
    } else {
      serial = (value as DoubleCellValue).value;
    }
    if (serial > 1 && serial < 200000) {
      final date = DateTime(1899, 12, 30).add(Duration(days: serial.toInt()));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  // String date — try multiple formats
  final str = _cellToString(cell);
  if (str.isEmpty) return null;

  // Try yyyy-MM-dd
  final isoRegex = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
  final isoMatch = isoRegex.firstMatch(str);
  if (isoMatch != null) return str;

  // Try dd.MM.yyyy or dd/MM/yyyy
  final dmyRegex = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$');
  final dmyMatch = dmyRegex.firstMatch(str);
  if (dmyMatch != null) {
    final d = dmyMatch.group(1)!.padLeft(2, '0');
    final m = dmyMatch.group(2)!.padLeft(2, '0');
    final y = dmyMatch.group(3)!;
    return '$y-$m-$d';
  }

  return null;
}
