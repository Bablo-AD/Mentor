import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color.fromARGB(255, 253, 249, 209),
    Colors.white,
  ];

  bool showAvg = false;
  Map<DateTime, int> journalFrequency = {};

  @override
  void initState() {
    super.initState();
    processJournals();
  }

  void processJournals() {
    // Assuming Data.journals is a Map<String, dynamic> with date strings as keys
    // Convert each date string to a DateTime and count occurrences
    journalFrequency = {};
    Data.journal.forEach((dateString, content) {
      DateTime date = DateTime.parse(dateString);
      // Use date or date.weekday depending on whether you want daily or weekly frequency
      journalFrequency.update(date, (value) => value + 1, ifAbsent: () => 1);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 10,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'Avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white);
    Widget text;
    switch (value.toInt()) {
      case 3:
        text = const Text('week 1', style: style);
        break;
      case 11:
        text = const Text('week 2', style: style);
        break;
      case 19:
        text = const Text('week 3', style: style);
        break;
      case 27:
        text = const Text('week 4', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 3:
        text = '🔥';
        break;
      case 2:
        text = '👍';
        break;
      case 1:
        text = '👊';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    DateTime now = DateTime.now();
    // Calculate the start and end of the current week
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    // Filter entries for the current week
    var weekEntries = journalFrequency.entries.where((entry) =>
        entry.key.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
        entry.key.isBefore(endOfWeek.add(Duration(days: 1))));

    // Group and sum entries by weekday
    var groupedWeekEntries = groupBy(
            weekEntries, (MapEntry<DateTime, int> entry) => entry.key.weekday)
        .map((weekday, entries) => MapEntry(
            weekday,
            entries.fold(
                0, (previousValue, entry) => previousValue + entry.value)));

    // Convert grouped entries to FlSpot instances
    List<FlSpot> weekSpots = groupedWeekEntries.entries.map((entry) {
      double x = entry.key.toDouble(); // Weekday (1 for Monday, 7 for Sunday)
      double y = entry.value.toDouble(); // Sum of values for the day
      return FlSpot(x, y);
    }).toList();

    // Create a set of days that already have entries
    Set<double> existingDays = weekSpots.map((spot) => spot.x).toSet();

    // Fill in missing days of the week with 0 value
    for (int day = 1; day <= 7; day++) {
      if (!existingDays.contains(day.toDouble())) {
        weekSpots.add(FlSpot(day.toDouble(), 0));
      }
    }

    // Sort the spots by weekday
    weekSpots.sort((a, b) => a.x.compareTo(b.x));
    print(weekSpots);
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          spots: weekSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    DateTime now = DateTime.now();
    var groupedEntries = groupBy(journalFrequency.entries,
            (MapEntry<DateTime, int> entry) => entry.key.day)
        .map((day, entries) => MapEntry(
            day,
            entries.fold(
                0, (previousValue, entry) => previousValue + entry.value)));

// Convert grouped entries to FlSpot instances
    List<FlSpot> spots = groupedEntries.entries.map((entry) {
      double x = entry.key.toDouble(); // Day of the month
      double y = entry.value.toDouble(); // Sum of values for the day
      return FlSpot(x, y);
    }).toList();
    List<FlSpot> filledSpots = List<FlSpot>.from(spots);

// Find the range of days in the month
    int totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;

// Create a set of days that already have entries
    Set<double> existingDays = spots.map((spot) => spot.x).toSet();

// Fill in missing days with 0 value
    for (int day = 1; day <= totalDaysInMonth; day++) {
      if (!existingDays.contains(day.toDouble())) {
        filledSpots.add(FlSpot(day.toDouble(), 0));
      }
    }

// Sort the spots by day of the month
    filledSpots.sort((a, b) => a.x.compareTo(b.x));

    //print(filledSpots);
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 31,
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          spots: filledSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
