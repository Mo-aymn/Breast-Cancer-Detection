import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportHistory extends StatefulWidget {
  @override
  _ReportHistoryState createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReports = prefs.getStringList('reports') ?? [];

    setState(() {
      reports = savedReports.map((report) => Map<String, dynamic>.from(jsonDecode(report))).toList();
    });
  }

  Future<void> _deleteReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      reports.removeAt(index);
    });
    List<String> updatedReports = reports.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('reports', updatedReports);
  }

  Future<void> _clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reports');
    setState(() {
      reports.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previous Reports"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _clearReports,
          ),
        ],
      ),
      body: reports.isEmpty
          ? Center(
        child: Text(
          "No reports available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text("Report ${index + 1}"),
              subtitle: Text("Date: ${reports[index]['date']}"),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReport(index),
              ),
              onTap: () {
                _showReportDialog(reports[index]['report']);
              },
            ),
          );
        },
      ),
    );
  }

  void _showReportDialog(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var key in report.keys)
                  Text("$key: ${report[key]}", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
