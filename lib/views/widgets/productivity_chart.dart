import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProductivityChart extends StatelessWidget {
  final Map<String, double> dataMap;

  const ProductivityChart({super.key, required this.dataMap});

  @override
  Widget build(BuildContext context) {
    // Jika data kosong, tampilkan pesan
    if (dataMap.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Belum ada data tugas",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // Tinggi grafik
      child: PieChart(
        PieChartData(
          sectionsSpace: 2, // Jarak antar potongan pie
          centerSpaceRadius: 40, // Lubang di tengah (Donut chart)
          sections: _buildChartSections(),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    return dataMap.entries.map((entry) {
      final category = entry.key;
      final count = entry.value;
      final color = _getCategoryColor(category);

      return PieChartSectionData(
        color: color,
        value: count,
        title: '${count.toInt()}', // Tampilkan angka di dalam potongan
        radius: 50, // Besar potongan
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah': return Colors.blueAccent;
      case 'pribadi': return Colors.greenAccent;
      case 'organisasi': return Colors.orangeAccent;
      case 'lainnya': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }
}