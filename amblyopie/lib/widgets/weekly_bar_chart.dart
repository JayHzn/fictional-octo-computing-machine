import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<int> values;
  const WeeklyBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final max = values.reduce((a, b) => a > b ? a : b);
    final maxY = (max <= 0 ? 1 : max).toDouble() + 1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i > 6) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i]),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: values[i].toDouble(), width: 16),
          ]);
        }),
      ),
    );
  }
}