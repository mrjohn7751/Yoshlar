import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class MultiResponsivePiePage extends StatelessWidget {
  const MultiResponsivePiePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final eduType = [
      {'category': "Мактаб ўқувчиси", 'sales': 450, 'color': Color(0xff3783D3)},
      {
        'category': "Лицей, Коллеж, Техникум ўқувчиси",
        'sales': 320,
        'color': Colors.teal,
      },
      {
        'category': "Олий таълим талабаси",
        'sales': 280,
        'color': Colors.orange,
      },
    ];
    //40cfa1, 9bd140, 3eccdf, F38433, 2DC3AC, 3783D3
    final eduType2 = [
      {'category': "Ўрта", 'sales': 150, 'color': Color(0xFF40cfa1)},
      {'category': "Ўрта махсус", 'sales': 210, 'color': Color(0xFFF38433)},
      {'category': "Олий", 'sales': 190, 'color': Color(0xFF9bd140)},
    ];
    final jopType = [
      {'category': "Ишлайди", 'sales': 100, 'color': const Color(0xFF66BB6A)},
      {'category': "Таълим олади", 'sales': 120, 'color': Color(0xFF2DC3AC)},
      {'category': "Ишсиз", 'sales': 80, 'color': Color(0xFF79C1E5)},
    ];

    // SingleChildScrollView ichida Expanded ishlatib bo'lmaydi,
    // shuning uchun Expanded o'rniga Column/Row o'zini qaytaramiz.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: isMobile
          ? Column(
              children: [
                SimplePieChart(title: "Таълим ҳолати", data: eduType),
                const SizedBox(height: 30),
                SimplePieChart(title: "Таълим ҳолати", data: eduType2),
                const SizedBox(height: 30),
                SimplePieChart(title: "Бандлик ҳолати", data: jopType),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SimplePieChart(title: "Таълим ҳолати", data: eduType),
                ),
                Expanded(
                  child: SimplePieChart(title: "Таълим ҳолати", data: eduType2),
                ),
                Expanded(
                  child: SimplePieChart(title: "Бандлик ҳолати", data: jopType),
                ),
              ],
            ),
    );
  }
}

class SimplePieChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data; // Turini aniqlab qo'yamiz

  const SimplePieChart({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Diagramma uchun aniq balandlik
            child: Chart(
              data: data,
              variables: {
                'category': Variable(
                  accessor: (Map map) => map['category'] as String,
                ),
                'sales': Variable(accessor: (Map map) => map['sales'] as num),
              },
              transforms: [Proportion(variable: 'sales', as: 'percent')],
              marks: [
                IntervalMark(
                  position: Varset('percent') / Varset('category'),
                  color: ColorEncode(
                    variable: 'category',
                    // MUHIM TUZATISH: .cast<Color>() qo'shildi
                    values: data
                        .map((e) => e['color'] as Color)
                        .toList()
                        .cast<Color>(),
                  ),
                  modifiers: [StackModifier()],
                  label: LabelEncode(
                    encoder: (tuple) => Label(
                      tuple['sales'].toString(),
                      LabelStyle(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              coord: PolarCoord(transposed: true, dimCount: 1, startRadius: 0),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: data
                .map(
                  (item) => _buildLegendItem(
                    item['category'] as String,
                    item['color'] as Color,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }
}
