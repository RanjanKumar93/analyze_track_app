import 'package:analyze_track/local/local_database.dart';
import 'package:analyze_track/models/track.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const ChartScreen({super.key, required this.dbHelper});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late List<_ChartData> data = [];
  late TooltipBehavior _tooltip;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
    _fetchExpensesAndPrepareData();
  }

  Future<void> _fetchExpensesAndPrepareData() async {
    // Fetch the expenses from the local database
    List<Track> expenses = await widget.dbHelper.getTracks();

    // Map the expenses to chart data (e.g., by category and total amount)
    Map<String, double> expenseByCategory = {};
    for (var expense in expenses) {
      if (expenseByCategory.containsKey(expense.category)) {
        expenseByCategory[expense.category] =
            expenseByCategory[expense.category]! + expense.amount;
      } else {
        expenseByCategory[expense.category] = expense.amount;
      }
    }

    // Prepare the chart data
    List<_ChartData> chartData = expenseByCategory.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    setState(() {
      data = chartData;
      isLoading = false; // Set loading to false after data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Chart'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfCircularChart(
              legend: const Legend(
                  isVisible: true, position: LegendPosition.bottom),
              tooltipBehavior: _tooltip,
              series: <CircularSeries<_ChartData, String>>[
                DoughnutSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Tracks',
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x; // Category
  final double y; // Total amount spent in that category
}
