import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yoshlar/data/model/region.dart';

class RegionsBarChart extends StatelessWidget {
  final List<RegionModel> regions;

  const RegionsBarChart({super.key, required this.regions});

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) return const SizedBox();

    final maxY = regions.fold<int>(0, (max, r) => r.youthsCount > max ? r.youthsCount : max);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hududlar kesimida",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxY + 5).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitles(value, meta),
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(regions.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: regions[index].youthsCount.toDouble(),
            color: const Color(0xFF3384C3),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    final index = value.toInt();
    if (index < 0 || index >= regions.length) return const SizedBox();

    String text = regions[index].name;
    if (text.length > 3) text = text.substring(0, 3).toUpperCase();

    return SideTitleWidget(
      space: 10,
      meta: meta,
      child: Text(text, style: style),
    );
  }
}
