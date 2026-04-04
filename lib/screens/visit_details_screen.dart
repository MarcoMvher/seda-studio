import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import '../models/visit.dart';
import '../models/measurement.dart';
import '../providers/visit_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../widgets/error_display.dart';

// Helper functions for display names (used in PDF generation)
String getWindowTypeDisplayName(String windowType) {
  switch (windowType) {
    case 'jarar':
      return 'جرار';
    case 'mufsala':
      return 'مفصلي';
    default:
      return windowType;
  }
}

// Helper function to get display name for detail type
String getDetailTypeDisplayName(String detailType) {
  switch (detailType) {
    case 'normal':
      return 'تفصيل عادي';
    case 'crushing':
      return 'تفصيل تكسير';
    case 'wave':
      return 'تفصيل ويفي';
    case 'rings':
      return 'تفصيل حلقات';
    case 'roll_up':
      return 'رول اب';
    default:
      return detailType;
  }
}

String _getFullImageUrl(String imageUrl) {
  // Convert relative URL to absolute URL
  if (imageUrl.startsWith('http')) {
    // Force HTTPS to prevent mixed content issues
    if (imageUrl.startsWith('http://')) {
      return imageUrl.replaceFirst('http://', 'https://');
    }
    return imageUrl;
  }
  // Remove leading slash if present
  final path = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
  return '${AppConfig.baseUrl}/$path';
}

// Class to hold a single measurement row data
class MeasurementRow {
  final String id;
  final TextEditingController spaceNameController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController omqController;
  final TextEditingController suqutController;
  final TextEditingController trackController;
  final TextEditingController windowToCeilingController;
  String? windowType; // jarar, mufsala
  String? detailType; // normal, crushing, wave, rings, roll_up
  bool hasCurtain;
  bool hasWood;
  String? generalNotes; // ملاحظات عامة

  // Image handling
  String? imagePath;
  dynamic imageData; // Can be File for mobile or XFile for web
  String? existingImageUrl; // For editing - keeps existing image URL

  MeasurementRow()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        spaceNameController = TextEditingController(),
        widthController = TextEditingController(),
        heightController = TextEditingController(),
        omqController = TextEditingController(),
        suqutController = TextEditingController(),
        trackController = TextEditingController(),
        windowToCeilingController = TextEditingController(),
        windowType = null,
        detailType = null,
        hasCurtain = false,
        hasWood = false,
        generalNotes = null,
        imagePath = null,
        imageData = null;

  void dispose() {
    spaceNameController.dispose();
    widthController.dispose();
    heightController.dispose();
    omqController.dispose();
    suqutController.dispose();
    trackController.dispose();
    windowToCeilingController.dispose();
  }
}

class VisitDetailsScreen extends StatefulWidget {
  final int visitId;

  const VisitDetailsScreen({super.key, required this.visitId});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  bool _isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    _loadVisit();
  }

  Future<void> _loadVisit() async {
    final visitProvider = context.read<VisitProvider>();
    await visitProvider.loadVisit(widget.visitId);
  }

  Future<bool> _onWillPop() async {
    if (_isShowingDialog) return false;

    final visitProvider = context.read<VisitProvider>();
    final visit = visitProvider.selectedVisit;

    print('DEBUG: _onWillPop called, visit status: ${visit?.status}');

    if (visit != null && visit.status == 'in_progress') {
      print('DEBUG: Showing completion dialog');
      setState(() {
        _isShowingDialog = true;
      });

      final shouldComplete = await _showCompletionDialog(context);

      setState(() {
        _isShowingDialog = false;
      });

      print('DEBUG: User chose to complete: $shouldComplete');

      if (shouldComplete == true) {
        print('DEBUG: Updating visit status to completed');
        await visitProvider.updateVisitStatus(visit.id, 'completed');
      }
    } else {
      print('DEBUG: No dialog shown, visit is null or status is: ${visit?.status}');
    }

    return true;
  }

  Future<bool?> _showCompletionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completeVisit),
        content: Text(l10n.completeVisitConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, int visitId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelVisit),
        content: Text(l10n.cancelVisitConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final visitProvider = context.read<VisitProvider>();
      await visitProvider.cancelVisit(visitId);

      if (context.mounted) {
        if (visitProvider.error != null) {
          context.showErrorSnackBar(visitProvider.error!);
          visitProvider.clearError();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.visitCancelled),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      // TODO: Upload image
      if (mounted) {
        context.showErrorSnackBar(
          'ميزة رفع الصور - قيد التطوير',
        );
      }
    }
  }

  // Helper method to get all images (visit images + measurement images)
  List<Map<String, String?>> _getAllImages() {
    final List<Map<String, String?>> allImages = [];
    final visitProvider = context.read<VisitProvider>();
    final visit = visitProvider.selectedVisit;

    if (visit == null) return allImages;

    // Add visit images
    if (visit.images != null) {
      for (final image in visit.images!) {
        allImages.add({
          'url': image.imageUrl,
          'caption': image.caption,
          'type': 'visit',
        });
      }
    }

    // Add measurement images
    if (visit.measurements != null) {
      for (final measurement in visit.measurements!) {
        if (measurement.imageUrl != null || measurement.image != null) {
          allImages.add({
            'url': measurement.imageUrl ?? measurement.image,
            'caption': '${measurement.spaceName}\n${measurement.widthCm}x${measurement.heightCm} سم',
            'type': 'measurement',
          });
        }
      }
    }

    return allImages;
  }

  Future<void> _showAddMeasurementDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final visitProvider = context.read<VisitProvider>();
    final visit = visitProvider.selectedVisit;

    final result = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => AddMeasurementDialog(visit: visit),
    );

    if (result != null && mounted) {
      final visitProvider = context.read<VisitProvider>();

      // Add all measurements
      for (var measurementData in result) {
        await visitProvider.addMeasurement(widget.visitId, measurementData);

        // Check for error after each measurement
        if (visitProvider.error != null && mounted) {
          context.showErrorSnackBar(visitProvider.error!);
          visitProvider.clearError();
          break;
        }
      }

      // Show success message if no errors
      if (mounted && visitProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${result.length} قياس'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditMeasurementDialog(Measurement measurement) async {
    final l10n = AppLocalizations.of(context)!;
    final visitProvider = context.read<VisitProvider>();
    final visit = visitProvider.selectedVisit;

    final result = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => AddMeasurementDialog(
        measurement: measurement,
        visit: visit,
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final visitProvider = context.read<VisitProvider>();
      final measurementData = result[0]; // Only one measurement when editing

      await visitProvider.updateMeasurement(measurement.id, measurementData);

      if (mounted) {
        if (visitProvider.error != null) {
          context.showErrorDialog(visitProvider.error!);
          visitProvider.clearError();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث القياس'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  List<pw.Widget> _buildMeasurementsSection(Visit visit, pw.Font primaryFont, List<pw.Font> fallbackFont, pw.TextDirection textDirection) {
    print('PDF: _buildMeasurementsSection called');
    print('PDF: visit.measurements.length = ${visit.measurements?.length}');

    final widgets = <pw.Widget>[
      pw.Text('القياسات',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          font: primaryFont,
          fontFallback: fallbackFont,
        ),
        textDirection: textDirection,
      ),
      pw.SizedBox(height: 10),
    ];

    if (visit.measurements != null && visit.measurements!.isNotEmpty) {
      print('PDF: Processing ${visit.measurements!.length} measurements');

      for (var i = 0; i < visit.measurements!.length; i++) {
        final measurement = visit.measurements![i];

        print('PDF: Measurement $i: ${measurement.spaceName}');

        // Simple text-based layout without containers
        widgets.add(pw.Text('قياس ${i + 1}: ${measurement.spaceName}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: primaryFont,
            fontFallback: fallbackFont,
          ),
          textDirection: textDirection,
        ));
        widgets.add(pw.SizedBox(height: 5));
        widgets.add(pw.Text('العرض: ${measurement.widthCm} سم | الارتفاع: ${measurement.heightCm} سم',
          style: pw.TextStyle(
            fontSize: 12,
            font: primaryFont,
            fontFallback: fallbackFont,
          ),
          textDirection: textDirection,
        ));
        widgets.add(pw.SizedBox(height: 5));

        // Window type
        if (measurement.windowType != null) {
          widgets.add(pw.Text('نوع الشباك: ${getWindowTypeDisplayName(measurement.windowType!)}',
            style: pw.TextStyle(
              fontSize: 12,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ));
          widgets.add(pw.SizedBox(height: 5));
        }

        // Detail type
        if (measurement.detailType != null) {
          widgets.add(pw.Text('نوع التفصيل: ${getDetailTypeDisplayName(measurement.detailType!)}',
            style: pw.TextStyle(
              fontSize: 12,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ));
          widgets.add(pw.SizedBox(height: 5));
        }

        // Curtain details
        if (measurement.hasCurtain) {
          widgets.add(pw.Text('بيت ستارة: نعم',
            style: pw.TextStyle(
              fontSize: 12,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ));
          if (measurement.omq != null) {
            widgets.add(pw.Text('العمق: ${measurement.omq} سم',
              style: pw.TextStyle(
                fontSize: 12,
                font: primaryFont,
                fontFallback: fallbackFont,
              ),
              textDirection: textDirection,
            ));
          }
          if (measurement.suqut != null) {
            widgets.add(pw.Text('السقوط: ${measurement.suqut} سم',
              style: pw.TextStyle(
                fontSize: 12,
                font: primaryFont,
                fontFallback: fallbackFont,
              ),
              textDirection: textDirection,
            ));
          }
          if (measurement.track != null) {
            widgets.add(pw.Text('التراك: ${measurement.track}',
              style: pw.TextStyle(
                fontSize: 12,
                font: primaryFont,
                fontFallback: fallbackFont,
              ),
              textDirection: textDirection,
            ));
          }
          if (measurement.hasWood) {
            widgets.add(pw.Text('خشب: نعم',
              style: pw.TextStyle(
                fontSize: 12,
                font: primaryFont,
                fontFallback: fallbackFont,
              ),
              textDirection: textDirection,
            ));
          }
        }

        if (measurement.windowToCeiling != null) {
          widgets.add(pw.Text('من الشباك للسقف: ${measurement.windowToCeiling} سم',
            style: pw.TextStyle(
              fontSize: 12,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ));
        }

        if (measurement.notes != null && measurement.notes!.isNotEmpty) {
          widgets.add(pw.Text('ملاحظات: ${measurement.notes}',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ));
        }

        widgets.add(pw.SizedBox(height: 10));
        widgets.add(pw.Divider(color: PdfColors.grey300));
      }
    }

    print('PDF: Returning ${widgets.length} widgets');
    return widgets;
  }

  Future<void> _exportToPDF() async {
    final l10n = AppLocalizations.of(context)!;
    final visitProvider = context.read<VisitProvider>();
    final visit = visitProvider.selectedVisit;

    if (visit == null) return;

    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Ensure measurements are loaded before export
      Visit visitToExport = visit;
      print('PDF Export: Measurements count: ${visit.measurements?.length ?? 0}');
      print('PDF Export: Measurements data: ${visit.measurements}');

      // Always reload to get fresh data with measurements
      print('PDF Export: Reloading visit data...');
      await visitProvider.loadVisit(visit.id);
      if (!mounted) return;

      final updatedVisit = visitProvider.selectedVisit;
      if (updatedVisit == null) {
        print('PDF Export: Failed to reload visit');
        Navigator.pop(context);
        if (mounted) {
          context.showErrorSnackBar('فشل تحميل بيانات الزيارة');
        }
        return;
      }

      visitToExport = updatedVisit;
      print('PDF Export: After reload - Measurements count: ${visitToExport.measurements?.length ?? 0}');
      if (visitToExport.measurements != null && visitToExport.measurements!.isNotEmpty) {
        print('PDF Export: First measurement: ${visitToExport.measurements![0].spaceName}');
      }

      // Get current locale
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

      // Create PDF
      final pdf = pw.Document();

      // Load fonts from assets (works on web and mobile)
      final arabicFontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      final arabicFont = pw.Font.ttf(arabicFontData);
      final latinFont = pw.Font.helvetica();

      // Select font based on locale
      final primaryFont = isArabic ? arabicFont : latinFont;
      final fallbackFont = isArabic ? [latinFont] : <pw.Font>[];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            // Debug: Print measurements count at PDF generation time
            print('PDF Build: measurements count = ${visitToExport.measurements?.length ?? 0}');
            print('PDF Build: measurements list = ${visitToExport.measurements}');

            return pw.Directionality(
              textDirection: textDirection,
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Text('تقرير الزيارة',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: primaryFont,
                      fontFallback: fallbackFont,
                    ),
                    textDirection: textDirection,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Customer Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('بيانات العميل',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: primaryFont,
                          fontFallback: fallbackFont,
                        ),
                        textDirection: textDirection,
                      ),
                      pw.SizedBox(height: 10),
                      if (visitToExport.customerDetails != null) ...[
                        _buildPdfRow('الاسم:', visitToExport.customerDetails!.name, primaryFont, fallbackFont, textDirection),
                        if (visitToExport.customerDetails!.phone != null)
                          _buildPdfRow('الهاتف:', visitToExport.customerDetails!.phone!, primaryFont, fallbackFont, textDirection),
                        if (visitToExport.customerDetails!.address != null)
                          _buildPdfRow('العنوان:', visitToExport.customerDetails!.address!, primaryFont, fallbackFont, textDirection),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Visit Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('بيانات الزيارة',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: primaryFont,
                          fontFallback: fallbackFont,
                        ),
                        textDirection: textDirection,
                      ),
                      pw.SizedBox(height: 10),
                      _buildPdfRow('رقم الزيارة:', '#${visitToExport.id}', primaryFont, fallbackFont, textDirection),
                      _buildPdfRow('الحالة:', _getStatusText(visitToExport.status), primaryFont, fallbackFont, textDirection),
                      if (visitToExport.scheduledAt != null)
                        _buildPdfRow('التاريخ المجدول:', visitToExport.scheduledAt.toString(), primaryFont, fallbackFont, textDirection),
                      if (visitToExport.notes != null)
                        _buildPdfRow('ملاحظات:', visitToExport.notes!, primaryFont, fallbackFont, textDirection),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Measurements Section
                ..._buildMeasurementsSection(visitToExport, primaryFont, fallbackFont, textDirection),
                pw.SizedBox(height: 20),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'تم إنشاء هذا التقرير بواسطة تطبيق SEDA Studio',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                      font: primaryFont,
                      fontFallback: fallbackFont,
                    ),
                    textDirection: textDirection,
                  ),
                ),
              ],
            ),
            );
          },
        ),
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show print/preview dialog
      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'visit_${visitToExport.id}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        context.showErrorSnackBar(e);
      }
    }
  }

  pw.Widget _buildPdfRow(String label, String value, pw.Font primaryFont, List<pw.Font> fallbackFont, pw.TextDirection textDirection) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: primaryFont,
              fontFallback: fallbackFont,
            ),
            textDirection: textDirection,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl, String? caption) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imageUrl: imageUrl,
          caption: caption,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.visitDetails),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportToPDF,
              tooltip: 'تصدير إلى PDF',
            ),
            Consumer<VisitProvider>(
              builder: (context, visitProvider, _) {
                final visit = visitProvider.selectedVisit;
                if (visit == null) return const SizedBox();

                // Show cancel button only for pending or in_progress visits
                if (visit.status == 'pending' || visit.status == 'in_progress') {
                  return IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _showCancelDialog(context, visit.id),
                    tooltip: l10n.cancelVisit,
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      body: Consumer<VisitProvider>(
        builder: (context, visitProvider, _) {
          final visit = visitProvider.selectedVisit;

          if (visitProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (visitProvider.error != null) {
            return ErrorDisplay(
              error: visitProvider.error!,
              onRetry: _loadVisit,
            );
          }

          if (visit == null) {
            return Center(
              child: Text('الزيارة غير موجودة'),
            );
          }

          // Debug logging
          print('DEBUG VisitDetails: delegateName = ${visit.delegateName}');
          print('DEBUG VisitDetails: delegateId = ${visit.delegateId}');
          print('DEBUG VisitDetails: full visit data = ${visit.toJson()}');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visit Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.visit} #${visit.id}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: l10n.customer,
                          value: visit.customerDetails?.name ?? 'غير معروف',
                        ),
                        if (visit.delegateName != null)
                          _InfoRow(
                            label: l10n.delegateLabel,
                            value: visit.delegateName!,
                          )
                        else
                          _InfoRow(
                            label: l10n.delegateLabel,
                            value: 'غير معروف',
                          ),
                        _InfoRow(
                          label: l10n.status,
                          value: visit.statusDisplay,
                        ),
                        if (visit.scheduledAt != null)
                          _InfoRow(
                            label: l10n.scheduled,
                            value: visit.scheduledAt.toString(),
                          ),
                        if (visit.notes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.notes}: ${visit.notes}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Measurements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.measurements,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    // Only show add button for non-branch users
                    if (!context.watch<AuthProvider>().isBranchUser)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddMeasurementDialog,
                        tooltip: l10n.addMeasurement,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (visit.measurements == null || visit.measurements!.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.straighten,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noMeasurementsYet,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addFirstMeasurement,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...visit.measurements!.map((measurement) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(Icons.straighten),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        measurement.spaceName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${l10n.width}: ${measurement.widthCm}cm x ${l10n.height}: ${measurement.heightCm}cm',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                // Only show edit/delete buttons for non-branch users and non-completed visits
                                if (!context.watch<AuthProvider>().isBranchUser && visit.status != 'completed')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditMeasurementDialog(measurement),
                                        tooltip: 'تعديل',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(l10n.deleteMeasurement),
                                              content: Text(l10n.deleteMeasurementConfirm),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, false),
                                                  child: Text(l10n.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  child: Text(l10n.delete),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true && mounted) {
                                            await visitProvider
                                              .deleteMeasurement(measurement.id);
                                          if (mounted) {
                                            if (visitProvider.error != null) {
                                              context.showErrorSnackBar(visitProvider.error!);
                                              visitProvider.clearError();
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('تم حذف القياس'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Window and detail type badges
                            if (measurement.windowType != null || measurement.detailType != null)
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (measurement.windowType != null)
                                    Chip(
                                      label: Text(
                                        getWindowTypeDisplayName(measurement.windowType!),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.green[100],
                                      padding: EdgeInsets.zero,
                                    ),
                                  if (measurement.detailType != null)
                                    Chip(
                                      label: Text(
                                        getDetailTypeDisplayName(measurement.detailType!),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.purple[100],
                                      padding: EdgeInsets.zero,
                                    ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            // Details
                            if (measurement.hasCurtain ||
                                measurement.hasWood ||
                                measurement.windowToCeiling != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (measurement.hasCurtain) ...[
                                    const Text('بيت ستارة: نعم',
                                        style: TextStyle(fontSize: 13)),
                                    if (measurement.omq != null)
                                      Text('العمق: ${measurement.omq} سم',
                                          style: const TextStyle(fontSize: 13)),
                                    if (measurement.suqut != null)
                                      Text('السقوط: ${measurement.suqut} سم',
                                          style: const TextStyle(fontSize: 13)),
                                    if (measurement.track != null)
                                      Text('التراك: ${measurement.track}',
                                          style: const TextStyle(fontSize: 13)),
                                  ],
                                  if (measurement.hasWood)
                                    const Text('خشب: نعم',
                                        style: TextStyle(fontSize: 13)),
                                  if (measurement.windowToCeiling != null)
                                    Text('من الشباك للسقف: ${measurement.windowToCeiling} سم',
                                        style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            // Measurement image
                            if (measurement.imageUrl != null || measurement.image != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    _showImageViewer(
                                      context,
                                      _getFullImageUrl(measurement.imageUrl ?? measurement.image!),
                                      '${measurement.spaceName}\n${measurement.widthCm}x${measurement.heightCm} سم',
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _getFullImageUrl(measurement.imageUrl ?? measurement.image!),
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 100,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image, size: 32),
                                                SizedBox(height: 4),
                                                Text('فشل تحميل الصورة',
                                                    style: TextStyle(fontSize: 12)),
                                                Text(
                                                  _getFullImageUrl(measurement.imageUrl ?? measurement.image!),
                                                  style: TextStyle(fontSize: 8, color: Colors.red),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            if (measurement.notes != null && measurement.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'ملاحظات: ${measurement.notes}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),

                // Images Section
                Text(
                  l10n.photos,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (_getAllImages().isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.image, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noPhotosYet,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _getAllImages().length,
                    itemBuilder: (context, index) {
                      final imageData = _getAllImages()[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            if (imageData['url'] != null) {
                              _showImageViewer(context, imageData['url']!, imageData['caption']);
                            }
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (imageData['url'] != null)
                                Image.network(
                                  imageData['url']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                )
                              else
                                const Center(
                                  child: Icon(Icons.image),
                                ),
                              if (imageData['caption'] != null)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black54,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      imageData['caption']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );
  }
}

class AddMeasurementDialog extends StatefulWidget {
  final Measurement? measurement; // Add this for editing
  final Visit? visit; // Visit to check status for location capture

  const AddMeasurementDialog({super.key, this.measurement, this.visit});

  @override
  State<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<AddMeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<MeasurementRow> _rows = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(MeasurementRow());
    });
  }

  void _removeRow(int index) {
    setState(() {
      if (_rows.length > 1) {
        _rows[index].dispose();
        _rows.removeAt(index);
      }
    });
  }

  Future<void> _pickImageForRow(int index) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          _rows[index].imageData = pickedFile;
          _rows[index].imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      context.showErrorSnackBar(e);
    }
  }

  void _removeImageForRow(int index) {
    setState(() {
      _rows[index].imageData = null;
      _rows[index].imagePath = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final results = <Map<String, dynamic>>[];

      // Capture location only if visit status is 'in_progress'
      // NOTE: Location capture disabled due to Flutter compatibility issues
      // Requires Flutter upgrade to enable geolocator package
      double? latitude;
      double? longitude;

      // TODO: Enable location capture after Flutter upgrade
      // if (widget.visit != null && widget.visit!.status == 'in_progress') {
      //   try {
      //     LocationPermission permission = await Geolocator.checkPermission();
      //     if (permission == LocationPermission.denied) {
      //       permission = await Geolocator.requestPermission();
      //     }
      //     if (permission == LocationPermission.whileInUse ||
      //         permission == LocationPermission.always) {
      //       final position = await Geolocator.getCurrentPosition(
      //         desiredAccuracy: LocationAccuracy.medium,
      //       );
      //       latitude = position.latitude;
      //       longitude = position.longitude;
      //     }
      //   } catch (e) {
      //     print('Error getting location: $e');
      //   }
      // }

      for (var row in _rows) {
        if (row.spaceNameController.text.trim().isEmpty &&
            row.widthController.text.trim().isEmpty &&
            row.heightController.text.trim().isEmpty) {
          continue; // Skip empty rows
        }

        final result = {
          'space_name': row.spaceNameController.text.trim().isEmpty
              ? 'قياس ${results.length + 1}'
              : row.spaceNameController.text.trim(),
          'width_cm': row.widthController.text.trim().isEmpty
              ? 0.0
              : double.parse(row.widthController.text),
          'height_cm': row.heightController.text.trim().isEmpty
              ? 0.0
              : double.parse(row.heightController.text),
          if (row.windowType != null) 'window_type': row.windowType,
          if (row.detailType != null) 'detail_type': row.detailType,
          'has_curtain': row.hasCurtain,
          if (row.omqController.text.trim().isNotEmpty)
            'omq': double.tryParse(row.omqController.text),
          if (row.suqutController.text.trim().isNotEmpty)
            'suqut': double.tryParse(row.suqutController.text),
          if (row.trackController.text.trim().isNotEmpty)
            'track': row.trackController.text.trim(),
          'has_wood': row.hasWood,
          if (row.windowToCeilingController.text.trim().isNotEmpty)
            'window_to_ceiling': double.tryParse(row.windowToCeilingController.text),
          if (row.imageData != null) 'image': row.imageData,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (row.generalNotes != null && row.generalNotes!.trim().isNotEmpty)
            'notes': row.generalNotes!.trim(),
        };

        // Add measurement ID if editing
        if (widget.measurement != null) {
          result['id'] = widget.measurement!.id;
        }

        results.add(result);
      }

      if (results.isNotEmpty) {
        Navigator.of(context).pop(results);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى ملء حقل واحد على الأقل'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final measurement = widget.measurement;
    if (measurement != null) {
      // Pre-fill data for editing
      setState(() {
        final row = MeasurementRow();

        // Fill basic fields
        row.spaceNameController.text = measurement.spaceName ?? '';
        row.widthController.text = measurement.widthCm?.toString() ?? '';
        row.heightController.text = measurement.heightCm?.toString() ?? '';
        row.windowType = measurement.windowType;
        row.detailType = measurement.detailType;

        // Fill curtain-related fields
        row.hasCurtain = measurement.hasCurtain ?? false;
        if (measurement.omq != null) {
          row.omqController.text = measurement.omq.toString();
        }
        if (measurement.suqut != null) {
          row.suqutController.text = measurement.suqut.toString();
        }
        if (measurement.track != null) {
          row.trackController.text = measurement.track!;
        }

        // Fill other fields
        row.hasWood = measurement.hasWood ?? false;
        if (measurement.windowToCeiling != null) {
          row.windowToCeilingController.text = measurement.windowToCeiling.toString();
        }

        // Fill notes (extract from combined notes field if needed)
        if (measurement.notes != null) {
          row.generalNotes = measurement.notes!;
        }

        // Keep existing image URL
        if (measurement.imageUrl != null) {
          row.existingImageUrl = measurement.imageUrl;
        }

        _rows.add(row);
      });
    } else {
      // Add one initial row for new measurement
      _addRow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.measurement != null ? 'تعديل القياس' : l10n.addMeasurement,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    final row = _rows[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row header with remove button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'قياس ${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                if (_rows.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeRow(index),
                                    tooltip: 'حذف هذا الصف',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Section 1: اسم الشباك بالمقاس
                            _buildSectionHeader(context, '١. اسم الشباك بالمقاس'),
                            const SizedBox(height: 8),
                            // Window name field (full width)
                            TextFormField(
                              controller: row.spaceNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم الشباك *',
                                hintText: 'مثال: شباك غرفة المعيشة',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              textDirection: TextDirection.rtl,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال اسم الشباك';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            // Width and Length fields in one row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: row.widthController,
                                    decoration: const InputDecoration(
                                      labelText: 'العرض (سم) *',
                                      border: OutlineInputBorder(),
                                      suffixText: 'سم',
                                      isDense: true,
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'يرجى إدخال العرض';
                                      }
                                      if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                                        return 'يرجى إدخال قيمة صحيحة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: row.heightController,
                                    decoration: const InputDecoration(
                                      labelText: 'الطول (سم) *',
                                      border: OutlineInputBorder(),
                                      suffixText: 'سم',
                                      isDense: true,
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'يرجى إدخال الطول';
                                      }
                                      if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                                        return 'يرجى إدخال قيمة صحيحة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Section 2: نوع الشباك
                            _buildSectionHeader(context, '٢. نوع الشباك'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: row.windowType,
                              decoration: const InputDecoration(
                                labelText: 'نوع الشباك',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'jarar', child: Text('جرار', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'mufsala', child: Text('مفصلي', textDirection: TextDirection.rtl)),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  row.windowType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // Section 3: نوع التفصيل
                            _buildSectionHeader(context, '٣. نوع التفصيل'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: row.detailType,
                              decoration: const InputDecoration(
                                labelText: 'نوع التفصيل',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'normal', child: Text('تفصيل عادي', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'crushing', child: Text('تفصيل تكسير', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'wave', child: Text('تفصيل ويفي', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'rings', child: Text('تفصيل حلقات', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'roll_up', child: Text('رول اب', textDirection: TextDirection.rtl)),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  row.detailType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // Section 4: من الشباك للسقف
                            _buildSectionHeader(context, '٤. من الشباك للسقف'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: row.windowToCeilingController,
                              decoration: const InputDecoration(
                                labelText: 'من الشباك للسقف (سم)',
                                border: OutlineInputBorder(),
                                suffixText: 'سم',
                                isDense: true,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                            const SizedBox(height: 12),

                            // Section 5: تراك
                            _buildSectionHeader(context, '٥. تراك'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: row.trackController.text.isNotEmpty ? row.trackController.text : null,
                              decoration: const InputDecoration(
                                labelText: 'نوع التراك',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'KS', child: Text('KS', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'تراك حبل', child: Text('تراك حبل', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'تراك دوران', child: Text('تراك دوران', textDirection: TextDirection.rtl)),
                                DropdownMenuItem(value: 'ماسوره', child: Text('ماسوره', textDirection: TextDirection.rtl)),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  row.trackController.text = value ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // Section 6: بيت ستارة
                            _buildSectionHeader(context, '٦. بيت ستارة'),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              title: const Text('بيت ستارة', textDirection: TextDirection.rtl),
                              value: row.hasCurtain,
                              onChanged: (value) {
                                setState(() {
                                  row.hasCurtain = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (row.hasCurtain)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: row.omqController,
                                            decoration: const InputDecoration(
                                              labelText: 'عمق (سم)',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: row.suqutController,
                                            decoration: const InputDecoration(
                                              labelText: 'سقوط (سم)',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    CheckboxListTile(
                                      title: const Text('خشب', textDirection: TextDirection.rtl),
                                      value: row.hasWood,
                                      onChanged: (value) {
                                        setState(() {
                                          row.hasWood = value ?? false;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 8),
                                    // ملاحظات عامة under بيت ستارة
                                    TextFormField(
                                      initialValue: row.generalNotes,
                                      decoration: const InputDecoration(
                                        labelText: 'ملاحظات عامة',
                                        hintText: 'أضف ملاحظات هنا...',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      maxLines: 2,
                                      textDirection: TextDirection.rtl,
                                      onChanged: (value) {
                                        row.generalNotes = value.trim().isEmpty ? null : value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),

                            // Image picker
                            _buildSectionHeader(context, 'صورة القياس'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (row.imagePath != null)
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Image.file(
                                          File(row.imagePath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeImageForRow(index),
                                        tooltip: 'حذف الصورة',
                                      ),
                                    ],
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImageForRow(index),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('إضافة صورة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[100],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Save button - full width
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.save),
                  label: Text('حفظ الكل (${_rows.length})'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Add window button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة شباك'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
}

class _ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const _ImageViewerScreen({
    required this.imageUrl,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'عرض الصورة',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'فشل في تحميل الصورة',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.all(16),
                child: Text(
                  caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
