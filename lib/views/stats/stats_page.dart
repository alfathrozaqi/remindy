import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../widgets/productivity_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengakses ViewModel
    final taskViewModel = Provider.of<TaskViewModel>(context);
    
    // Pastikan data refresh saat halaman ini dibuka
    // Menggunakan addPostFrameCallback agar tidak error saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Opsional: Jika ingin auto-refresh realtime
      // taskViewModel.fetchTasks(); 
    });

    final categoryData = taskViewModel.getCategoryStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAGIAN 1: CHART ---
          const Text(
            "Jenis Tugas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          
          ProductivityChart(dataMap: categoryData),
          
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.blueAccent, "Kuliah"),
              _buildLegendItem(Colors.greenAccent, "Pribadi"),
              _buildLegendItem(Colors.orangeAccent, "Organisasi"),
            ],
          ),

          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // --- BAGIAN 2: RINGKASAN ---
          const Text(
            "Ringkasan Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "To-do", 
                  "${taskViewModel.todoCount}", 
                  Icons.pending_actions, 
                  Colors.orange
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Selesai", 
                  "${taskViewModel.completedCount}", 
                  Icons.check_circle_outline, 
                  Colors.green
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // --- BAGIAN 3: HISTORY ---
          const Text(
            "History Tracking",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Kamu telah menyelesaikan ${taskViewModel.completedCount} tugas sejauh ini. Pertahankan semangatmu!",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          
          // Tambahan padding bawah agar tidak tertutup navbar
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}