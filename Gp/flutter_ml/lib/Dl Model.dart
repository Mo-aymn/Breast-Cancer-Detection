import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ml/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'report_history.dart';

class MlModel extends StatefulWidget {
  @override
  State<MlModel> createState() => _MlModelState();
}

class _MlModelState extends State<MlModel> {
  Map<String, dynamic>? report;
  final picker = ImagePicker();
  File? img;
  var baseUrl = "http://192.168.1.9:5000";
  bool isDetailedAnalysis = false;
  bool isLoading = false;

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        img = File(pickedFile.path);
        report = null;
      });
    }
  }

  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        img = File(pickedFile.path);
        report = null;
      });
    }
  }

  Future upload() async {
    if (img == null) return;

    setState(() {
      isLoading = true;
      report = {"status": "Processing..."};
    });

    final endpoint =
        isDetailedAnalysis ? "/predict/detailed" : "/predict/simple";
    final request =
        http.MultipartRequest("POST", Uri.parse(baseUrl + endpoint));
    request.files.add(http.MultipartFile(
      'file',
      img!.readAsBytes().asStream(),
      img!.lengthSync(),
      filename: img!.path.split('/').last,
    ));

    try {
      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(res.body);

        // معالجة الاستجابة بناءً على نوع التحليل
        if (isDetailedAnalysis) {
          setState(() {
            report = responseData;
          });
        } else {
          setState(() {
            report = {
              "report_date":
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              "processed_image": responseData['file'],
              "predictions": {
                "Result":
                    "${responseData['class']} (${(responseData['confidence'] * 100).toStringAsFixed(2)}%)"
              },
              "Notes": responseData['class'] == "Cancer"
                  ? "Based on this finding, it is advisable to see a specialist immediately."
                  : "No signs of cancer detected. Regular checkups are recommended."
            };
          });
        }

        saveReport(report!);
        showReportDialog(context);
      } else {
        setState(() {
          report = {"error": "Error: ${response.statusCode}"};
        });
      }
    } catch (e) {
      setState(() {
        report = {"error": "Request failed: $e"};
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveReport(Map<String, dynamic> newReport) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reports = prefs.getStringList('reports') ?? [];

    String formattedReport = jsonEncode({
      "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "analysis_type": isDetailedAnalysis ? "Detailed" : "Simple",
      "report": newReport
    });

    reports.add(formattedReport);
    await prefs.setStringList('reports', reports);
  }

  void generatePDF() async {
    if (report == null) return;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  "Medical Report - ${isDetailedAnalysis ? 'Detailed' : 'Basic'} Analysis",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Report Date: ${report!["report_date"]}"),
              pw.Text("Processed Image: ${report!["processed_image"]}"),
              pw.SizedBox(height: 10),
              pw.Text("Predictions:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (isDetailedAnalysis)
                for (var key in report!["predictions"].keys)
                  pw.Text("$key: ${report!["predictions"][key]}"),
              if (!isDetailedAnalysis)
                pw.Text("${report!["predictions"]["Result"]}"),
              pw.SizedBox(height: 10),
              pw.Text("Notes: ${report!["Notes"]}",
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void showReportDialog(BuildContext context) {
    if (report == null || report!.containsKey("error")) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(report?["error"] ?? "Unknown error occurred"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Medical Report - ${isDetailedAnalysis ? 'Detailed' : 'Basic'} Analysis"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Report Date: ${report!["report_date"]}"),
                Text("Processed Image: ${report!["processed_image"]}"),
                SizedBox(height: 10),
                Text("Predictions:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (isDetailedAnalysis)
                  for (var key in report!["predictions"].keys)
                    Text("$key: ${report!["predictions"][key]}"),
                if (!isDetailedAnalysis)
                  Text("${report!["predictions"]["Result"]}"),
                SizedBox(height: 10),
                Text("Notes: ${report!["Notes"]}",
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
            ElevatedButton(
              onPressed: generatePDF,
              child: Text("Download PDF"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : AppColors.secondary;
    final Color primaryColor = isDarkMode ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Breast Cancer Analysis',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportHistory()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Preview
            Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.tealAccent, Colors.blueGrey]
                      : [Colors.blue, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: img == null
                    ? Image.asset('assets/img-onboarding.png',
                        fit: BoxFit.cover)
                    : Image.file(img!, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: 20),

            // Analysis Type Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Analysis Type:",
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Switch(
                  value: isDetailedAnalysis,
                  onChanged: (value) {
                    setState(() {
                      isDetailedAnalysis = value;
                    });
                  },
                  hoverColor: AppColors.primary,
                  focusColor: AppColors.primary,
                  overlayColor: WidgetStatePropertyAll(AppColors.primary),
                  activeColor: AppColors.primary,
                ),
                Text(isDetailedAnalysis ? "Detailed" : "Basic",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),

            SizedBox(height: 10),

            // Buttons
            _buildButton(
                "Pick Image from Gallery", pickImageFromGallery, primaryColor),
            SizedBox(height: 10),
            _buildButton(
                "Take Photo from Camera", pickImageFromCamera, primaryColor),
            SizedBox(height: 10),

            if (img != null) ...[
              _buildButton(
                "Analyze Image",
                upload,
                isLoading ? Colors.grey : Colors.orangeAccent,
                isLoading: isLoading,
              ),
              SizedBox(height: 10),
              _buildButton(
                "Remove Image",
                () {
                  setState(() {
                    img = null;
                    report = null;
                  });
                },
                Colors.redAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color,
      {bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
