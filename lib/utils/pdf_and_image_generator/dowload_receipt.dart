import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart'; // Replace image_gallery_saver

import '../../models/transaction_model.dart';

Future<void> downloadTransactionReceipt({
  required SpecificTransactionData transaction,
  required BuildContext context,
  required GlobalKey receiptKey,
  String format = 'pdf', // 'pdf' or 'image'
}) async {
  try {
    // Request storage permission
    bool permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission required to download receipt')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating receipt...'),
              ],
            ),
          ),
        );
      },
    );

    if (format == 'pdf') {
      await _generatePdfReceipt(transaction, context);
    } else {
      // Fix for rendering issue - give the UI time to finish rendering
      await Future.delayed(const Duration(milliseconds: 600));
      await _generateImageReceipt(receiptKey, context, transaction);
    }

    // Close loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt downloaded successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    // Close loading dialog if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to download receipt: ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Receipt generation error: ${e.toString()}');
  }
}
Future<String> getSaveDirectory() async {
  if (Platform.isAndroid) {
    // Get the Android API level
    // If running on Android 13+, also request photos permission
    if (int.parse(await _getAndroidSdkVersion()) >= 33) {
      var photosStatus = await Permission.photos.request();

      // Use app-specific directory
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;}

  } else {
    // For iOS or other platforms
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  return "";
}

Future<bool> _requestPermissions() async {
  if (!Platform.isAndroid) {
    // For iOS or other platforms
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  // Android platform specific code
  try {
    // For all Android versions, try regular storage permission first
    var status = await Permission.storage.request();

    // If running on Android 13+, also request photos permission
    if (int.parse(await _getAndroidSdkVersion()) >= 33) {
      var photosStatus = await Permission.photos.request();
      return status.isGranted || photosStatus.isGranted;
    }

    return status.isGranted;
  } catch (e) {
    debugPrint('Error requesting permissions: $e');
    // Fallback to basic permission
    var status = await Permission.storage.request();
    return status.isGranted;
  }
}

Future<String> _getAndroidSdkVersion() async {
  try {
    final Map<String, dynamic> buildVersion =
    await const MethodChannel('plugins.flutter.io/package_info').invokeMethod('getBuildVersion');
    return buildVersion['sdkInt']?.toString() ?? '0';
  } catch (e) {
    debugPrint('Error getting SDK version: $e');
    return '0';  // Default to lowest version on error
  }
}

Future<void> _generatePdfReceipt(SpecificTransactionData transaction, BuildContext context) async {
  final pdf = pw.Document();
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

  // Load custom font (e.g., Roboto) that supports Unicode characters
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  // Define a default text style with the fallback font
  final defaultTextStyle = pw.TextStyle(font: ttf, fontFallback: [ttf]);

  // Convert transaction values
  double? amount = double.tryParse(transaction.amount?.toString() ?? '0');
  double? balAfter = double.tryParse(transaction.balAfter?.toString() ?? '0');
  double? fee = double.tryParse(transaction.fee?.toString() ?? '0');
  double? totalAmount = double.tryParse(transaction.totalAmount?.toString() ?? '0');

  // Check if transaction is credit or debit
  final isCredit = transaction.type.toLowerCase() == 'credit';
  final statusColor = _getPdfColor(transaction.status);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                'Transaction Receipt',
                style: defaultTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'FUSTPAY',
                style: defaultTextStyle.copyWith(
                  fontSize: 16,
                  color: PdfColor.fromInt(0xFF666666),
                ),
              ),
              pw.SizedBox(height: 32),

              // Amount display
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                decoration: pw.BoxDecoration(
                  color: isCredit
                      ? PdfColor.fromInt(0xFFECF8F3)
                      : PdfColor.fromInt(0xFFFDEDEE),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      '${isCredit ? '+' : '-'} ${formatter.format(amount)}',
                      style: defaultTextStyle.copyWith(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: isCredit
                            ? PdfColor.fromInt(0xFF0A8754)
                            : PdfColor.fromInt(0xFFE63946),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: statusColor,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        transaction.status,
                        style: defaultTextStyle.copyWith(
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Details
              _buildPdfDetailSection(
                'Transaction Details',
                [
                  {'label': 'Transaction ID', 'value': transaction.trxID},
                  {
                    'label': 'Date & Time',
                    'value': DateFormat('MMMM d, yyyy • HH:mm').format(transaction.timeCreated),
                  },
                  {'label': 'Type', 'value': transaction.type},
                  {
                    'label': (transaction.action == "Data" || transaction.action == "Airtime")
                        ? "Description"
                        : "Account",
                    'value': transaction.accountName
                  },
                  {'label': 'Action', 'value': transaction.action},
                ],
                defaultTextStyle,
              ),
              pw.SizedBox(height: 16),

              _buildPdfDetailSection(
                'Financial Details',
                [
                  {'label': 'Amount', 'value': formatter.format(amount)},
                  {'label': 'Fee', 'value': formatter.format(fee)},
                  {'label': 'Total Amount', 'value': formatter.format(totalAmount)},
                  {'label': 'Balance After', 'value': formatter.format(balAfter)},
                ],
                defaultTextStyle,
              ),
              pw.SizedBox(height: 16),

              _buildPdfDetailSection(
                'Additional Information',
                [
                  {'label': 'Narration', 'value': transaction.narration},
                ],
                defaultTextStyle,
              ),

              pw.Spacer(),
              pw.Text(
                'Thank you for using our service',
                style: defaultTextStyle.copyWith(
                  fontSize: 12,
                  color: PdfColor.fromInt(0xFF888888),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Receipt generated on ${DateFormat('MMMM d, yyyy • HH:mm').format(DateTime.now())}',
                style: defaultTextStyle.copyWith(
                  fontSize: 10,
                  color: PdfColor.fromInt(0xFF888888),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Get directory to save file
  final dirPath = await getSaveDirectory();
  final fileName = 'Transaction_${transaction.trxID}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
  final filePath = '$dirPath/$fileName';
  final file = File(filePath);

  // Save PDF
  await file.writeAsBytes(await pdf.save());

  // Share the file
  await Share.shareXFiles(
    [XFile(filePath)],
    text: 'Transaction Receipt',
  );
}

Future<void> _generateImageReceipt(GlobalKey receiptKey, BuildContext context, SpecificTransactionData transaction) async {
  try {
    // Ensure the widget is fully rendered
    await Future.delayed(const Duration(milliseconds: 200));

    // Get render object
    final RenderRepaintBoundary? boundary =
    receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Cannot find the widget to capture. Make sure the key is properly attached.');
    }

    // Force a repaint if needed
    boundary.markNeedsPaint();
    await Future.delayed(const Duration(milliseconds: 200));

    // Set a reasonable pixel ratio that won't cause memory issues
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to capture receipt as image');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // Get temporary directory to save the image
    final dirPath = await getSaveDirectory();
    final fileName = 'Transaction_${transaction.trxID}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final filePath = '$dirPath/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);


    // Create a directory for your app's images if it doesn't exist
    final appImagesDir = Directory('$dirPath/Transaction_Receipts');
    if (!await appImagesDir.exists()) {
      await appImagesDir.create(recursive: true);
    }

    // Save to app's external directory (visible in gallery)
    final savedFilePath = '${appImagesDir.path}/$fileName';
    final savedFile = File(savedFilePath);
    await savedFile.writeAsBytes(pngBytes);

    // Share the image
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Transaction Receipt',
    );
  } catch (e) {
    debugPrint('Image capture error: $e');

    // If image capture fails, fall back to PDF
    await _generatePdfReceipt(
      transaction,
      context,
    );
  }
}

pw.Widget _buildPdfDetailSection(String title, List<Map<String, String>> details, pw.TextStyle defaultTextStyle) {
  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromInt(0xFFEEEEEE)),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF5F5F5),
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(12),
              topRight: pw.Radius.circular(12),
            ),
          ),
          child: pw.Text(
            title,
            style: defaultTextStyle.copyWith(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            children: details.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text(
                        '${item['label']}:',
                        style: defaultTextStyle.copyWith(color: PdfColor.fromInt(0xFF666666)),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Text(
                        item['value'] ?? '',
                        style: defaultTextStyle.copyWith(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

PdfColor _getPdfColor(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return PdfColor.fromInt(0xFF0A8754);
    case 'pending':
      return PdfColor.fromInt(0xFFF9A826);
    case 'failed':
      return PdfColor.fromInt(0xFFE63946);
    default:
      return PdfColor.fromInt(0xFF888888);
  }
}