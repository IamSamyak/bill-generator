import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PdfViewerDialogContent extends StatefulWidget {
  final String path;

  const PdfViewerDialogContent({Key? key, required this.path})
    : super(key: key);

  @override
  _PdfViewerDialogContentState createState() => _PdfViewerDialogContentState();
}

class _PdfViewerDialogContentState extends State<PdfViewerDialogContent> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set a max height and width for the dialog
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final maxWidth = MediaQuery.of(context).size.width * 0.9;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ), // Reduced padding
              decoration: BoxDecoration(
                color:
                    Theme.of(context).appBarTheme.backgroundColor ??
                    Colors.blue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bill Preview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Slightly reduced font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    iconSize: 20, // Reduced icon size
                    padding: EdgeInsets.zero, // Remove extra padding
                    constraints:
                        const BoxConstraints(), // Prevent default size constraints
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // White background container around the PDF viewer
            Expanded(
              child: SfPdfViewerTheme(
                data: SfPdfViewerThemeData(
                  backgroundColor: Colors.white, // PDF canvas background
                ),
                child: SfPdfViewer.file(
                  File(widget.path),
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  scrollDirection: PdfScrollDirection.vertical,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
