import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers của các Thành viên
import 'features/quan_dashboard_topics/topic_manager_service.dart';
import 'features/muoi_dictionary_algo/recommendation_algo.dart';
import 'features/vu_duo_game/game_controller.dart';

// Màn hình chính của 4 Thành viên
import 'features/quan_dashboard_topics/learning_dashboard_screen.dart';
import 'features/nam_flashcard_media/topic_list_screen.dart';
import 'features/muoi_dictionary_algo/dictionary_screen.dart';
import 'features/vu_duo_game/duo_game_lobby_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LangMasterApp());
}

/// Ứng dụng Học Ngôn Ngữ Đa Phương Tiện & Game Hóa (LangMaster)
/// PRM393 - Đồ án Nhóm 4 thành viên
class LangMasterApp extends StatelessWidget {
  const LangMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Member 1 Provider: Quản lý Chủ đề, Custom Topics & Thống kê Streak
        ChangeNotifierProvider<TopicManagerProvider>(
          create: (_) => TopicManagerProvider(),
        ),
        // Member 3 Provider: Thuật toán Gợi ý và Top 10 từ sai (Urgency Score S)
        ChangeNotifierProvider<MistakeAlgorithmProvider>(
          create: (_) => MistakeAlgorithmProvider(),
        ),
        // Member 4 Provider: Game đối kháng tốc độ 1v1 & Đấu Bot (Timer 3.5s & Strike Combo)
        ChangeNotifierProvider<DuoGameController>(
          create: (_) => DuoGameController(),
        ),
      ],
      child: MaterialApp(
        title: 'LangMaster',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            primary: const Color(0xFF4F46E5),
            surface: const Color(0xFFF8FAFC),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF1E293B)),
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

/// Màn hình điều hướng chính chia đều 4 Tab độc lập cho 4 thành viên:
/// - Tab 1: Dashboard Thống kê học tập, Daily Streak & Tạo chủ đề (Member 1 - Leader)
/// - Tab 2: Chủ đề Flashcard & Tải Đa phương tiện Image/Audio/Video (Member 2)
/// - Tab 3: Từ điển, Kiểm tra Gõ & Nhận diện Giọng nói AI (Member 3)
/// - Tab 4: Game Đấu tốc độ 1v1 Đối kháng ngược chiều & Đấu Bot (Member 4)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LearningDashboardScreen(), // Tab 1: Member 1 (Leader)
    TopicListScreen(),         // Tab 2: Member 2
    DictionaryScreen(),        // Tab 3: Member 3
    DuoGameLobbyScreen(),      // Tab 4: Member 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
          elevation: 0,
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon:
                  Icon(Icons.dashboard_rounded, color: Color(0xFF4F46E5)),
              label: 'Tiến độ',
            ),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style_rounded, color: Color(0xFF4F46E5)),
              label: 'Flashcard',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon:
                  Icon(Icons.menu_book_rounded, color: Color(0xFF4F46E5)),
              label: 'Từ điển',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon:
                  Icon(Icons.sports_esports_rounded, color: Color(0xFF4F46E5)),
              label: 'Duo Game',
            ),
          ],
        ),
      ),
    );
  }
}


