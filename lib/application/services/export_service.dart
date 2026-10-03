/// تصدير البيانات CSV/PDF — بند §10. CSV بترميز UTF-8 مع BOM ليعمل في Excel.
/// PDF بخط Cairo مضمّن مع إعادة تشكيل العربية (reshaper + bidi) لعرض سليم.
library;

import 'dart:convert';
import 'dart:io';

import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;
import 'package:csv/csv.dart' as csv;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/data/repositories/repositories.dart';

class ExportResult {
  final File file;
  final int rows;
  const ExportResult({required this.file, required this.rows});
}

class ExportService {
  /// تصدير CSV — رأس عربي + BOM حتى يعرض Excel العربية صحيحة.
  Future<ExportResult> exportCsv(List<HourlyVitalsAvg> rows) async {
    final header = <String>['الوقت', 'النبض', 'التنفس', 'الأكسجين %'];
    final data = <List<Object?>>[header];
    for (final r in rows) {
      data.add([
        _fmtTime(r.bucketStart),
        r.hr?.toStringAsFixed(0) ?? '',
        r.resp?.toStringAsFixed(0) ?? '',
        r.spo2?.toStringAsFixed(0) ?? '',
      ]);
    }
    final csvStr = const csv.ListToCsvConverter().convert(data);
    final bytes = utf8.encode('\uFEFF$csvStr'); // BOM + نص
    final file = await _writeFile('asthma_care_report.csv', bytes);
    return ExportResult(file: file, rows: rows.length);
  }

  /// تصدير PDF — جدول بعنوان وملاحظة حدية واضحة.
  Future<ExportResult> exportPdf(List<HourlyVitalsAvg> rows) async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    final font = pw.Font.ttf(fontData);
    final bold = pw.Font.ttf(boldData);

    final doc = pw.Document();
    final shapedTitle = _ar('تقرير AsthmaCare — السجل الطبي');
    final shapedNote = _ar('بيانات جهاز المراقبة — للتوعية الشخصية وليست تشخيصًا طبيًا');

    final tableRows = rows
        .map((r) => [
              _ar(_fmtTime(r.bucketStart)),
              r.hr?.toStringAsFixed(0) ?? '-',
              r.resp?.toStringAsFixed(0) ?? '-',
              r.spo2?.toStringAsFixed(0) ?? '-',
            ])
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text(shapedTitle, style: pw.TextStyle(font: bold, fontSize: 18)),
          pw.SizedBox(height: 4),
          pw.Text(shapedNote,
              style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              _ar('الوقت'),
              _ar('النبض'),
              _ar('التنفس'),
              _ar('الأكسجين %'),
            ],
            headerStyle:
                pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.white),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromInt(Aurora.brand.toARGB32())),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            data: tableRows,
            cellAlignment: pw.Alignment.center,
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final file = await _writeFile('asthma_care_report.pdf', bytes);
    return ExportResult(file: file, rows: rows.length);
  }

  // ───────── أدوات داخلية ─────────

  /// إعادة تشكيل العربية لعرض صحيح في PDF (أشكال الحروف + الاتجاه البصري).
  String _ar(String text) {
    try {
      final reshaped = ArabicReshaper().reshape(text);
      return String.fromCharCodes(bidi.logicalToVisual(reshaped));
    } catch (_) {
      // تعذر التشكيل — نص خام (يُراجع في الدمج)
      return text;
    }
  }

  String _fmtTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:00';
  }

  Future<File> _writeFile(String name, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final exports = Directory('${dir.path}/exports');
    if (!await exports.exists()) {
      await exports.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${exports.path}/${name}_$stamp');
    await file.writeAsBytes(bytes);
    return file;
  }
}
