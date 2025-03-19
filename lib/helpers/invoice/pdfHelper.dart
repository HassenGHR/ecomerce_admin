import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pdfx/pdfx.dart'; // Replace syncfusion with pdfx
import 'package:share_plus/share_plus.dart';

Future<void> requestPermissions() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {
    print('Storage permission is not granted.');
  }
}

class PdfHelper {
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    // Request storage permission
    await requestPermissions();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    Directory? appDocumentsDir;
    if (Platform.isAndroid) {
      if (androidInfo.version.sdkInt >= 30) {
        appDocumentsDir = await getDownloadsDirectory();
      } else {
        appDocumentsDir = await getExternalStorageDirectory();
      }
    }
    final file = File('${appDocumentsDir!.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static void openPdfViewer(BuildContext context, File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(file: file),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final File file;

  PdfViewerPage({required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('وصل التسليم', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: PdfView(
        controller: PdfController(
            document: PdfDocument.openFile(file.path)), // Use pdfx here
      ),
      floatingActionButton: _buildFloatingContainer(context, theme),
    );
  }

  Widget _buildFloatingContainer(BuildContext context, ThemeData theme) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {
        _showOptions(context, theme);
      },
      child: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
    );
  }

  void _showOptions(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl, // Set the text direction to RTL
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.save),
                title: Text('حفظ إلى الجهاز',
                    style: theme
                        .textTheme.titleMedium), // "Save to Device" in Arabic
                onTap: () async {
                  try {
                    Navigator.pop(context);
                    final savedFile = await PdfHelper.saveDocument(
                      name: '${DateTime.now()}-OasisDelivery.pdf',
                      pdf: pw.Document(), // Replace with your actual document
                    );
                    Fluttertoast.showToast(
                      msg:
                          'تم حفظ ملف الوصل بنجاح', // "PDF saved successfully" in Arabic
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green, // Green background color
                      textColor: Colors.white, // White text color
                      fontSize: 16.0,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'حدث خطأ: $e', // "An error occurred" in Arabic
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor:
                          Colors.red, // Red background color for errors
                      textColor: Colors.white, // White text color
                      fontSize: 16.0,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(
                  'مشاركة',
                  style: theme.textTheme.titleMedium,
                ), // "Share" in Arabic
                onTap: () async {
                  Navigator.pop(context);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    sharePositionOrigin: Rect.fromCircle(
                      radius: MediaQuery.of(context).size.width * 0.25,
                      center: const Offset(0, 0),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
