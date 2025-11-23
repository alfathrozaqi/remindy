import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task; // Jika null = Mode Tambah, Jika ada isi = Mode Edit

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  String _selectedCategory = 'Kuliah'; // Default kategori
  int _selectedPriority = 2; // Default: Sedang (1: Rendah, 2: Sedang, 3: Tinggi)
  bool _isReminderActive = true;

  final List<String> _categories = ['Kuliah', 'Pribadi', 'Organisasi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi Controller
    _titleController = TextEditingController();
    _descController = TextEditingController();

    // Jika Mode Edit, isi form dengan data lama
    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _selectedDate = t.deadline;
      _selectedTime = TimeOfDay.fromDateTime(t.deadline);
      _selectedCategory = t.category;
      _selectedPriority = t.priority;
      _isReminderActive = t.isReminderActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi Pilih Tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      // Tema DatePicker Gelap
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1F1F1F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Fungsi Pilih Jam
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1F1F1F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // Fungsi Simpan Data
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // 1. Gabungkan Tanggal dan Jam menjadi DateTime
      final deadlineDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // 2. Buat Object TaskModel
      final newTask = TaskModel(
        id: widget.task?.id, // Pakai ID lama jika edit, null jika baru
        title: _titleController.text,
        description: _descController.text,
        deadline: deadlineDateTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        isReminderActive: _isReminderActive,
        isCompleted: widget.task?.isCompleted ?? 0,
      );

      // 3. Panggil ViewModel untuk simpan ke SQLite
      final viewModel = Provider.of<TaskViewModel>(context, listen: false);
      
      if (widget.task == null) {
        viewModel.addTask(newTask); // Mode Tambah
      } else {
        viewModel.updateTask(newTask); // Mode Edit
      }

      // 4. Kembali ke Home
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
        actions: [
          // Tombol Save di pojok kanan atas (opsional, ada juga di bawah)
          IconButton(
            onPressed: _saveTask,
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INPUT JUDUL ---
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                ),
                validator: (val) => val!.isEmpty ? 'Nama tugas wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // --- INPUT DESKRIPSI ---
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 20),

              // --- PILIH KATEGORI & PRIORITAS (Baris) ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1F1F1F),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedPriority,
                      dropdownColor: const Color(0xFF1F1F1F),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Rendah")),
                        DropdownMenuItem(value: 2, child: Text("Sedang")),
                        DropdownMenuItem(value: 3, child: Text("Tinggi")),
                      ],
                      onChanged: (val) => setState(() => _selectedPriority = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- DEADLINE PICKER ---
              const Text("Deadline", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('EEE, d MMM y').format(_selectedDate)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_selectedTime.format(context)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- REMINDER TOGGLE ---
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Set Reminder", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Notifikasi lokal aktif", style: TextStyle(color: Colors.white54, fontSize: 12)),
                value: _isReminderActive,
                activeColor: Colors.blue,
                onChanged: (val) => setState(() => _isReminderActive = val),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL SAVE & CANCEL ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white54),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black, // Teks hitam pada tombol putih
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Save Task", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}