import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_navigator.dart';
import 'services/iap_purchase_service.dart';
import 'services/wallet_service.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/gallery_page.dart';
import 'pages/message_page.dart';
import 'pages/profile_page.dart';
import 'services/custom_chatbot_service.dart';
import 'services/discover_bot_service.dart';
import 'services/follow_state_service.dart';
import 'services/user_posts_service.dart';
import 'services/user_stats_service.dart';
import 'widgets/bubble_background.dart';
import 'widgets/dismiss_keyboard_scope.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPostsService.init();
  await FollowStateService.init();
  await UserStatsService.init();
  DiscoverBotService.init();
  await CustomChatbotService.init();
  unawaited(WalletService.load());
  unawaited(IapPurchaseService.init());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const CystoApp());
}

class CystoApp extends StatelessWidget {
  const CystoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Cysto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _kThemeColor,
          primary: _kThemeColor,
          brightness: Brightness.light,
        ),
        primaryColor: _kThemeColor,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          scrolledUnderElevation: 0,
          elevation: 0,
          foregroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.black87),
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _kThemeColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kThemeColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _kThemeColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: _kThemeColor,
          unselectedItemColor: Colors.grey.shade600,
        ),
      ),
      home: const MainScreen(),
      builder: (context, child) {
        return DismissKeyboardScope(
          child: BubbleBackground(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<GalleryPageState> _galleryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          const DiscoverPage(),
          GalleryPage(key: _galleryKey),
          const MessagePage(),
          const ProfilePage(),
        ],
      ),
      extendBody: false,
      bottomNavigationBar: _GlassCapsuleTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            DiscoverBotService.refresh();
            UserPostsService.reloadFromStorage();
          }
          if (index == 2) {
            _galleryKey.currentState?.refresh();
          }
        },
      ),
    );
  }
}

class _GlassCapsuleTabBar extends StatelessWidget {
  const _GlassCapsuleTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _tabBarHeight = 66.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _tabBarHeight + MediaQuery.of(context).padding.bottom,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: _tabBarHeight + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(33),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabItem(0, Icons.home_rounded, 'Home'),
                        _buildTabItem(1, Icons.explore_rounded, 'Discover'),
                        _buildTabItem(2, Icons.auto_awesome, 'Magic'),
                        _buildTabItem(3, Icons.chat_bubble_outline_rounded, 'Messages'),
                        _buildTabItem(4, Icons.person_rounded, 'Profile'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? _kThemeColor.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? _kThemeColor : Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: const Center(
        child: Text('Discover'),
      ),
    );
  }
}

