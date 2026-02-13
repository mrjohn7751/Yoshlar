import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/data/util/excel_parser.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';

class ImportYouthScreen extends StatefulWidget {
  static const String routeName = 'import_youth';

  const ImportYouthScreen({super.key});

  @override
  State<ImportYouthScreen> createState() => _ImportYouthScreenState();
}

enum _Phase { fileSelection, preview, results }

class _ImportYouthScreenState extends State<ImportYouthScreen> {
  _Phase _phase = _Phase.fileSelection;
  String? _fileName;
  List<Map<String, dynamic>> _parsedRows = [];
  List<ExcelParseError> _parseErrors = [];
  bool _isImporting = false;

  // Results
  int _successCount = 0;
  int _failedCount = 0;
  List<dynamic> _importErrors = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final parseResult = parseExcelBytes(file.bytes!);

    setState(() {
      _fileName = file.name;
      _parsedRows = parseResult.rows;
      _parseErrors = parseResult.errors;
      _phase = _Phase.preview;
    });
  }

  Future<void> _doImport() async {
    if (_parsedRows.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final response = await context.read<YouthService>().bulkImportYouths(_parsedRows);
      final results = response['results'] as Map<String, dynamic>?;

      setState(() {
        _successCount = results?['success'] ?? 0;
        _failedCount = results?['failed'] ?? 0;
        _importErrors = results?['errors'] ?? [];
        _phase = _Phase.results;
        _isImporting = false;
      });

      // Refresh youth list
      if (mounted && _successCount > 0) {
        context.read<YouthListCubit>().loadYouths();
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: ${safeErrorMessage(e)}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Import'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: switch (_phase) {
        _Phase.fileSelection => _buildFileSelection(),
        _Phase.preview => _buildPreview(),
        _Phase.results => _buildResults(),
      },
    );
  }

  Widget _buildFileSelection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 64, color: Colors.blue.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "Excel faylni yuklang",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ustunlar tartibi: F.I.Sh, Telefon, Jinsi, Tug'ilgan sana,\nTuman, Manzil, Ta'lim, Bandlik, Xavf darajasi, Toifalar",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Excel faylni tanlang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Header info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.description, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fileName ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${_parsedRows.length} ta qator tayyor, ${_parseErrors.length} ta xatolik',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _phase = _Phase.fileSelection;
                  _parsedRows = [];
                  _parseErrors = [];
                  _fileName = null;
                }),
                child: const Text("Boshqa fayl"),
              ),
            ],
          ),
        ),

        // Parse errors
        if (_parseErrors.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "O'tkazib yuborilgan qatorlar:",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange.shade800),
                ),
                const SizedBox(height: 4),
                ..._parseErrors.map((e) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "${e.row}-qator: ${e.message}",
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                      ),
                    )),
              ],
            ),
          ),

        // Data table
        Expanded(
          child: _parsedRows.isEmpty
              ? const Center(child: Text("Import qilinadigan ma'lumot topilmadi"))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('F.I.Sh', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Telefon', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Jinsi', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Sana', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tuman', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Manzil', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Ta'lim", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Bandlik', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Xavf', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Toifalar', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _parsedRows.asMap().entries.map((entry) {
                        final i = entry.key;
                        final r = entry.value;
                        final tags = (r['tags'] as List?)?.join(', ') ?? '';
                        return DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(r['name'] ?? '')),
                          DataCell(Text(r['phone'] ?? '')),
                          DataCell(Text(r['gender'] ?? '')),
                          DataCell(Text(r['birthDate'] ?? '')),
                          DataCell(Text(r['region'] ?? '')),
                          DataCell(Text(r['location'] ?? '')),
                          DataCell(Text(r['status'] ?? '')),
                          DataCell(Text(r['activity'] ?? '')),
                          DataCell(Text(r['riskLevel'] ?? '')),
                          DataCell(Text(tags)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
        ),

        // Bottom action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _parsedRows.isEmpty || _isImporting ? null : _doImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isImporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text("Import qilish (${_parsedRows.length} ta)"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            _failedCount == 0 ? Icons.check_circle : Icons.info,
            size: 72,
            color: _failedCount == 0 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            "Import yakunlandi",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _resultCard("Muvaffaqiyatli", _successCount, Colors.green),
              const SizedBox(width: 16),
              _resultCard("Xatolik", _failedCount, Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // Error details
          if (_importErrors.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Xatoliklar:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _importErrors.length,
                      itemBuilder: (context, i) {
                        final err = _importErrors[i] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red.shade100,
                                child: Text(
                                  '${err['row']}',
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      err['name'] ?? '—',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      err['message'] ?? '',
                                      style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            const Spacer(),

          // Done button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Tayyor"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
}
