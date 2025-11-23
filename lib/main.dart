import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/home/home_page.dart';
import 'core/utils/time_utils.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Timezone Helper
  TimeUtils.init();
  
  // 2. Inisialisasi Notification Service
  await NotificationService().init();

  runApp(const RemindyApp());
}

class RemindyApp extends StatelessWidget {
  const RemindyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final viewModel = TaskViewModel();
          
          viewModel.rescheduleAllNotifications(); 
          
          return viewModel;
        }),
      ],
      child: MaterialApp(
        title: 'Remindy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark, 
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            elevation: 0,
          ),
        ),
        home: const HomePage(), 
      ),
    );
  }
}