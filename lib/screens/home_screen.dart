import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../navigation/home_tab.dart';
import '../theme/app_colors.dart';
import '../widgets/action_bar_button.dart';
import '../widgets/app_bottom_nav.dart';
import 'catalog_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _profileEditing = false;

  final GlobalKey<NavigatorState> _searchNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _catalogNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  @override
  void initState() {
    super.initState();
    registerHomeTabSwitcher(_onHomeTabRequest);
  }

  @override
  void dispose() {
    unregisterHomeTabSwitcher();
    super.dispose();
  }

  void _onHomeTabRequest(int index) {
    
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    }
    _onTabTapped(index);
  }

  void _onTabTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      _searchNavKey.currentState?.popUntil((route) => route.isFirst);
    }
    if (index == 1 && _currentIndex == 1) {
      _catalogNavKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() {
      _currentIndex = index;
      if (index != 2) _profileEditing = false;
    });
    if (index == 2) {
      _profileKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: _searchNavKey,
            onGenerateRoute: (settings) {
              return CupertinoPageRoute(
                settings: settings,
                builder: (_) => const ColoredBox(
                  color: AppColors.bgPrimary,
                  child: SearchScreen(),
                ),
              );
            },
          ),
          Navigator(
            key: _catalogNavKey,
            onGenerateRoute: (settings) {
              return CupertinoPageRoute(
                settings: settings,
                builder: (_) => const ColoredBox(
                  color: AppColors.bgPrimary,
                  child: CatalogScreen(),
                ),
              );
            },
          ),
          ProfileScreen(
            key: _profileKey,
            onEditingChanged: (editing) {
              setState(() => _profileEditing = editing);
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        aboveBar: _profileEditing && _currentIndex == 2
            ? ActionBarButton(
                label: 'сохранить',
                onPressed: () => _profileKey.currentState?.save(),
              )
            : null,
      ),
    );
  }
}
