import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:amblyopie/pages/home/home_page.dart';
import 'package:amblyopie/pages/agenda/agenda_page.dart';
import 'package:amblyopie/pages/guide/guide_page.dart';
// import 'package:amblyopie/pages/notifications/notifications_page.dart';
// import 'package:amblyopie/pages/profile/profile_page.dart';

import 'package:amblyopie/models/appointment.dart';
import 'package:amblyopie/models/child.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _pageController = PageController();
  int _currentIndex = 0;

  late List<Child> _children;
  late List<Appointment> _appointments;

  static const double _navH = 64;
  static const double _navHPad = 12;
  static const double _navBPad = 2;

  // En attendant de lier la BDD
  @override
  void initState() {
    super.initState();

      _children = [
      Child(
        id: 'c1',
        firstName: 'Lina',
        birthDate: DateTime(2018, 5, 20),
      ),
      Child(
        id: 'c2',
        firstName: 'Noah',
        birthDate: DateTime(2017, 10, 3),
      ),
    ];

    _appointments = [
      Appointment(
        id: 'a1',
        childId: 'c1',
        title: 'Suivi ophtalmologique',
        date: DateTime(2025, 10, 15, 14, 30),
        location: 'Cabinet Dr. Dupuis',
      ),
      Appointment(
        id: 'a2',
        childId: 'c2',
        title: 'Contrôle',
        date: DateTime(2025, 10, 9, 10, 0),
        location: 'Clinique des Enfants',
      ),
    ];
  }

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

    final _pages = [
      const _KeepAlive(child: HomePage()),
      _KeepAlive(child: AgendaPage(children: _children, appointments: _appointments)),
      const _KeepAlive(child: GuidePage()),
      const _KeepAlive(child: NotificationsPage()),
      const _KeepAlive(child: ProfilePage()),
    ];

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
                      destinations: [
                        NavigationDestination(
                          icon: Image.asset('assets/logo/logo_graph.png', height: 32),
                          //selectedIcon: Icon(Icons.home),
                          label: 'Accueil',
                        ),
                        NavigationDestination(
                          icon: Image.asset('assets/logo/logo_agenda.png', height: 32),
                          //selectedIcon: Icon(Icons.event_note),
                          label: 'Agenda',
                        ),
                        NavigationDestination(
                          icon: Image.asset('assets/logo/logo_guide.png', height: 32),
                          //selectedIcon: Icon(Icons.book),
                          label: 'Guide',
                        ),
                        NavigationDestination(
                          icon: Image.asset('assets/logo/logo_question.png', height: 32),
                          //selectedIcon: Icon(Icons.notifications),
                          label: 'Notif',
                        ),
                        NavigationDestination(
                          icon: Image.asset('assets/logo/logo_profile.png', height: 32),
                          //selectedIcon: Icon(Icons.person),
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
