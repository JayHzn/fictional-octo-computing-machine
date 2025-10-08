import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:amblyopie/models/child.dart';
import 'package:amblyopie/models/appointment.dart';
import 'package:amblyopie/widgets/child_header_card.dart';
import 'package:amblyopie/widgets/weekly_bar_chart.dart';
import 'package:amblyopie/widgets/appointment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State <HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Child> _children = [];
  late List<Appointment> _appointments = [];

  late final PageController _pageController;
  int _currentIndex = 0;

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

    _pageController = PageController(
      viewportFraction: 0.55,
      initialPage: _currentIndex,
    );
  }

  Child get _currentChild => _children[_currentIndex];

    List<Appointment> get _currentAppointments {
    final list = _appointments
        .where((a) => a.childId == _currentChild.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<int> _weeklyCountsFor(String childId) {
    // Compte par jour (lundi→dimanche) uniquement pour l’enfant sélectionné
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: (now.weekday + 6) % 7));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7));

    final counts = List<int>.filled(7, 0);
    for (final a in _appointments.where((e) => e.childId == childId)) {
      final d = a.date;
      if (d.isAfter(start.subtract(const Duration(milliseconds: 1))) && d.isBefore(end)) {
        final idx = (d.weekday + 6) % 7; // lundi=0..dimanche=6
        counts[idx]++;
      }
    }
    return counts;
  }

  String _ageString(DateTime birth) {
    final now = DateTime.now();
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    if (now.day < birth.day) months--;
    if (months < 0) { years--; months += 12; }
    return years > 0 ? '$years ans${months > 0 ? ' $months mois' : ''}' : '$months mois';
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _goNext() {
    if (_currentIndex < _children.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final week = _weeklyCountsFor(_currentChild.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Précédent',
                  onPressed: _currentIndex == 0 ? null : _goPrev,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: SizedBox(
                    height: 120,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemCount: _children.length,
                      padEnds: false,
                      itemBuilder: (_, i) {
                        final c = _children[i];
                        final isCurrent = i == _currentIndex;
                        return AnimatedScale(
                          scale: isCurrent ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 200),
                          child: ChildHeaderCard(
                            child: c,
                            ageText: _ageString(c.birthDate),
                            isCurrent: isCurrent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Suivant',
                  onPressed: _currentIndex == _children.length - 1 ? null : _goNext,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text('À venir', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_currentAppointments.length}'),
              ],
            ),
            const SizedBox(height: 8),
            if (_currentAppointments.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun rendez-vous pour cette semaine.'),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < _currentAppointments.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppointmentCard(
                        appointment: _currentAppointments[i],
                        color: i.isEven
                            ? const Color(0xFFF58F5D)
                            : const Color(0xFF8FB4E3),
                        onTap: () {
                          
                        },
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 24),

            Text('Cette semaine', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: SizedBox(
                  height: 220,
                  child: WeeklyBarChart(values: week),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}