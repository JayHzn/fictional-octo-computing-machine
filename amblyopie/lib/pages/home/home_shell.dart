import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:amblyopie/pages/home/home_page.dart';
// import 'package:amblyopie/pages/agenda/agenda_page.dart';
// import 'package:amblyopie/pages/children/children_page.dart';
// import 'package:amblyopie/pages/notifications/notifications_page.dart';
// import 'package:amblyopie/pages/profile/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _pageController = PageController();
  int _currentIndex = 0;

  final _pages = const [
    _KeepAlive(child: HomePage()),
    _KeepAlive(child: AgendaPage()),
    _KeepAlive(child: ChildrenPage()),
    _KeepAlive(child: NotificationsPage()),
    _KeepAlive(child: ProfilePage()),
  ];

  static const double _navH = 64;
  static const double _navHPad = 12;
  static const double _navBPad = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapNav(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservedBottom = _navH + _navBPad;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: reservedBottom),
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                children: _pages,
              ),
            ),
          ),

          Positioned(
            left: _navHPad,
            right: _navHPad,
            bottom: _navBPad,
            child: SafeArea(
              top: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    elevation: 10,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.90),
                    child: NavigationBar(
                      height: _navH,
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onTapNav,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Accueil',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.event_note_outlined),
                          selectedIcon: Icon(Icons.event_note),
                          label: 'Agenda',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.family_restroom_outlined),
                          selectedIcon: Icon(Icons.family_restroom),
                          label: 'Enfants',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.notifications_none),
                          selectedIcon: Icon(Icons.notifications),
                          label: 'Notif',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profil',
                        ),
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
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Agenda')),
      );
}

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Enfants')),
      );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Notifications')),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Profil')),
      );
}
