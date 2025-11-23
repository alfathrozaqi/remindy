import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../widgets/task_card.dart';
import '../add_task/add_task_page.dart';
import '../stats/stats_page.dart';
import '../../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index 0 = Home, Index 1 = Stats
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks()
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().checkAndroidScheduleExactAlarmPermission(context);
    });
  }

  // Fungsi untuk mengganti halaman saat tombol navbar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);

    return Scaffold(
      // AppBar berubah judul sesuai halaman aktif
      appBar: AppBar(
        title: _selectedIndex == 0
          ? const Row(
              children: [
                Icon(Icons.notifications_active_outlined, size: 20),
                SizedBox(width: 8),
                Text("Remindy", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          : const Text("Laporan Produktivitas", style: TextStyle(fontWeight: FontWeight.bold)),
        
        // Hilangkan tombol back otomatis jika ada
        automaticallyImplyLeading: false,
      ),

      // BODY: Menggunakan IndexedStack atau Switch biasa
      // Di sini kita switch widget berdasarkan index
      body: _selectedIndex == 0
          ? _buildTaskList(taskViewModel) // Tampilkan List Tugas
          : const StatsPage(),            // Tampilkan Statistik (File yang tadi diedit)

      // FAB: Tetap Add Task (Muncul di kedua halaman, atau bisa disembunyikan di stats jika mau)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
      
      // NAVBAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color(0xFF1F1F1F),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TOMBOL KIRI: HOME
              IconButton(
                icon: Icon(
                  Icons.home_filled, 
                  // Jika aktif warnanya putih terang, jika tidak abu-abu
                  color: _selectedIndex == 0 ? Colors.white : Colors.white38,
                  size: 28,
                ),
                onPressed: () => _onItemTapped(0),
                tooltip: "Home",
              ),

              const SizedBox(width: 40), // Spasi untuk FAB di tengah
              
              // TOMBOL KANAN: STATS
              IconButton(
                icon: Icon(
                  Icons.bar_chart_rounded, 
                  // Jika aktif warnanya putih terang, jika tidak abu-abu
                  color: _selectedIndex == 1 ? Colors.white : Colors.white38,
                  size: 28,
                ),
                onPressed: () => _onItemTapped(1),
                tooltip: "Statistik",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET LIST TUGAS (Dipisahkan biar rapi) ---
  Widget _buildTaskList(TaskViewModel taskViewModel) {
    if (taskViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (taskViewModel.tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
      itemCount: taskViewModel.tasks.length,
      itemBuilder: (context, index) {
        final task = taskViewModel.tasks[index];
        
        // Bungkus TaskCard dengan Dismissible agar bisa digeser
        return Dismissible(
          key: ValueKey(task.id), // ID Unik wajib ada
          direction: DismissDirection.endToStart, // Geser dari kanan ke kiri
          
          // Background Merah (Tong Sampah) saat digeser
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          
          // Dialog Konfirmasi sebelum hapus (Opsional tapi disarankan)
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF2C2C2C),
                  title: const Text("Hapus Tugas?", style: TextStyle(color: Colors.white)),
                  content: Text(
                    "Apakah kamu yakin ingin menghapus '${task.title}'?",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false), // Batal
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // Hapus
                      child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                );
              },
            );
          },

          // Aksi saat benar-benar digeser (Hapus dari DB)
          onDismissed: (direction) {
            taskViewModel.deleteTask(task.id!);
            
            // Tampilkan feedback snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${task.title} dihapus"),
                action: SnackBarAction(
                  label: 'Undo',
                  // Fitur Undo sederhana (tambah lagi tugas yang sama)
                  onPressed: () => taskViewModel.addTask(task), 
                ),
              ),
            );
          },

          // Isi utamanya tetap TaskCard
          child: TaskCard(
            task: task,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskPage(task: task),
                ),
              );
            },
            onCheckboxChanged: (value) {
              taskViewModel.toggleTaskStatus(task);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.task_alt, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Belum ada tugas",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          Text(
            "Yuk mulai produktif hari ini!",
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }
}