import 'dart:io';
import 'dart:typed_data';
import 'package:AXMPAY/ui/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../models/transaction_model.dart';

class ReceiptGenerator {
  static Future<void> generatePdf(BuildContext context, ReceiptData receiptData) async {
    final pdf = pw.Document();
    double? amountTransfered = double.tryParse(receiptData?.order.amount.toString() ?? '0');
    double? merchantCharge = double.tryParse(receiptData?.merchant.merchantFeeAmount.toString() ?? '0');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Container(
                    width: 80,
                    height: 80,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green50,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Icon(
                      const pw.IconData(0xe876), // check icon
                      color: PdfColors.green,
                      size: 40,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Your transfer was successfully made to the recipient ${receiptData.order.amount}",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Total Paid",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
                pw.Text(
                  formatter.format(merchantCharge??0 + amountTransfered!),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  padding: pw.EdgeInsets.all(16),
                  child: pw.Column(
                    children: [
                      _buildDetailRow("Debited Amount", formatter.format(double.parse(receiptData.order.amount))),
                      _buildDetailRow("Mobile Number", receiptData.customer.account.sendername),
                      _buildDetailRow("bank", receiptData.customer.account.bank),
                      _buildDetailRow("charge", formatter.format(receiptData.merchant.merchantFeeAmount)),
                      _buildDetailRow("Remark", receiptData.narration),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: 14,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  static Future<void> captureAndSaveImage(BuildContext context, ScreenshotController screenshotController) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        final path = await _localPath;
        final file = File('$path/receipt${DateFormat('yyyy-MM-dd-ym').format(DateTime.timestamp())}.png');
        await file.writeAsBytes(imageBytes);
        await OpenFile.open(file.path);
      } else {
        throw Exception('Failed to capture screenshot');
      }
    } catch (e) {
      if(!context.mounted) return;
CustomPopup.show(context: context, title: "Error", message:'Failed to save image. Please try again.'
      );
    }
  }

  static Future<String> get _localPath async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      print("Failed to get directory: $e");
    }

    return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
  }
}