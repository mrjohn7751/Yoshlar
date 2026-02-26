import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:yoshlar/data/model/region.dart';

class RegionsBarChart extends StatelessWidget {
  final List<RegionModel> regions;

  const RegionsBarChart({super.key, required this.regions});

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) return const SizedBox();

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
            child: DChartBarO(
              renderType: (group) => RenderType.barLane,
              animate: true,
              defaultInteractions: false,
              allowSliding: false,
              arrangeVertically: false,
              configSeriesBarLane: ConfigSeriesBarLaneO(
                showBarLabel: true,

                // 🔥 measure ni chiqaramiz
                labelAccessor: (group, data, index) {
                  return data.measure.toString();
                },
              ),
              domainAxis: const DomainAxisO(showAxisLine: true),
              groupList: [
                OrdinalGroup(
                  id: 'id',
                  data: regions
                      .map(
                        (e) => OrdinalData(
                          domain: e.name.substring(0, 3).toUpperCase(),
                          measure: e.youthsCount,
                          measureLowerBound: e.youthsCount,
                          measureUpperBound: e.youthsCount,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
