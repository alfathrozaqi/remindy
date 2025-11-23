import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Function(bool?) onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, d MMM • HH:mm').format(task.deadline);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && task.isCompleted == 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      
      color: const Color(0xFF1F1F1F), // Warna latar kartu gelap
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white24, width: 1), // Garis tepi putih tipis
        borderRadius: BorderRadius.circular(12),
      ),
      // --------------------------------------------

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox Custom
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted == 1,
                  onChanged: onCheckboxChanged,
                  shape: const CircleBorder(),
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informasi Tugas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: task.isCompleted == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Badge Kategori
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(task.category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _getCategoryColor(task.category), width: 1),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getCategoryColor(task.category),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Deadline Text
                        Icon(
                          Icons.access_time, 
                          size: 12, 
                          color: isOverdue ? Colors.redAccent : Colors.grey
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.redAccent : Colors.grey,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah': return Colors.blueAccent;
      case 'pribadi': return Colors.greenAccent;
      case 'organisasi': return Colors.orangeAccent;
      default: return Colors.white70;
    }
  }
}