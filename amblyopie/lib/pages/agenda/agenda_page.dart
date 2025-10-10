import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:amblyopie/models/appointment.dart';
import 'package:amblyopie/models/child.dart';

class AgendaPage extends StatefulWidget {
  final List<Child> children;
  final List<Appointment> appointments;

  const AgendaPage({
    super.key,
    required this.children,
    required this.appointments,
  });

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  late Set<String> _selectedChildIds;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  late Map<DateTime, List<Appointment>> _eventsByDay;

  @override 
  void initState() {
    _focusedDay = DateTime.now();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _selectedChildIds = {
      ...widget.children.map((c) => c.id),
      '_noChild',
    };
    _eventsByDay = _buildEventsByDay();
  }

  DateTime _dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String _childIdOf(Appointment a) => a.childId ?? '_noChild';

  DateTime _startOf(Appointment a) => a.date;

  String _titleOf(Appointment a) => a.title;
  String? _subtitleOf(Appointment a) => a.subtitle;

  String? _locationOf(Appointment a) => a.location;

  List<Appointment> _eventLoader(DateTime day) {
    return _eventsByDay[_dayKey(day)] ?? [];
  }

  Map<DateTime, List<Appointment>> _buildEventsByDay() {
    final map = <DateTime, List<Appointment>>{};
    for (final appt in widget.appointments) {
      if (!_selectedChildIds.contains(_childIdOf(appt))) continue;
      final key = _dayKey(_startOf(appt));
      map.putIfAbsent(key, () => []).add(appt);
    }
    for (final list in map.values) {
      list.sort((a, b) => _startOf(a).compareTo(_startOf(b)));
    }
    return map;
  }

  List<Appointment> get _selectedDayAppointments {
    if (_selectedDay == null) return const [];
    return _eventLoader(_selectedDay!);
  }

  void _toggleChildFilter(String childId) {
    setState(() {
      if (_selectedChildIds.contains(childId)) {
        _selectedChildIds.remove(childId);
      } else {
        _selectedChildIds.add(childId);
      }
      _eventsByDay = _buildEventsByDay();
    });
  }

  void _selectAllChildren() {
    setState(() {
      _selectedChildIds = widget.children.map((c) => c.id).toSet();
      _eventsByDay = _buildEventsByDay();
    });
  }

  void _clearChildren() {
    setState(() {
      _selectedChildIds.clear();
      _eventsByDay = _buildEventsByDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyChildSelected = _selectedChildIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Column(
        children: [
          _FiltersBar(
            children: widget.children,
            selectedIds: _selectedChildIds,
            onToggle: _toggleChildFilter,
            onSelectAll: _selectAllChildren,
            onClear: _clearChildren,
          ),

          const Divider(height: 1),

          TableCalendar<Appointment>(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            onFormatChanged: (fmt) => setState(() => _calendarFormat = fmt),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _eventLoader,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders<Appointment>(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                final count = events.length.clamp(1, 3);
                return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      count,
                      (_) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hasAnyChildSelected
                    ? 'Rendez-vous du ${_formatDate(_selectedDay ?? _focusedDay)}'
                    : 'Aucun enfant sélectionné - aucun rendez-vous affiché',
                    style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: hasAnyChildSelected
              ? _AppointmentsList(
                  appointments: _selectedDayAppointments,
                  childById: {
                    for (final c in widget.children) c.id: c,
                  },
                  titleOf: _titleOf,
                  startOf: _startOf,
                  subtitleOf: _subtitleOf,
                  locationOf: _locationOf,
                  childIdOf: _childIdOf,
                )
              : const _EmptyState(
                message: 'Sélectionnez au moins un enfant pour voir les rendez-vous.',
              ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }
}

class _FiltersBar extends StatelessWidget {
  final List<Child> children;
  final Set<String> selectedIds;
  final void Function(String childId) onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  const _FiltersBar({
    required this.children,
    required this.selectedIds,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClear,
  });

   @override
   Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionChip(
            label: const Text('Tous'),
            avatar: const Icon(Icons.select_all),
            onPressed: onSelectAll,
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Aucun'),
            avatar: const Icon(Icons.block),
            onPressed: onClear,
          ),
          const SizedBox(width: 12),
          ...children.map((c) {
            final selected = selectedIds.contains(c.id);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c.firstName),
                selected: selected,
                onSelected: (_) => onToggle(c.id),
                avatar: const Icon(Icons.child_care),
              ),
            );
          }),
        ],
      ),
    );
   }
}

class _AppointmentsList extends StatelessWidget {
  final List<Appointment> appointments;
  final Map<String, Child> childById;

  final String Function(Appointment) titleOf;
  final DateTime Function(Appointment) startOf;
  final String? Function(Appointment) subtitleOf;
  final String? Function(Appointment) locationOf;
  final String Function(Appointment) childIdOf;

  const _AppointmentsList({
    required this.appointments,
    required this.childById,
    required this.titleOf,
    required this.startOf,
    required this.subtitleOf,
    required this.locationOf,
    required this.childIdOf,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const _EmptyState(message: 'Aucun rendez-vous ce jour.');
    }

    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final a = appointments[index];
        final child = childById[childIdOf(a)];

        final start = startOf(a);
        final timeStr = _fmtTime(start);

        return ListTile(
          leading: const Icon(Icons.event_note),
          title: Text(titleOf(a)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(timeStr),
              if (subtitleOf(a)?.isNotEmpty == true)
                Text(subtitleOf(a)!, style: const TextStyle(color: Colors.black87)),
              if (locationOf(a)?.isNotEmpty == true)
                Text(locationOf(a)!, style: const TextStyle(color: Colors.black54)),
              Text(
                'Enfant: ${child?.firstName ?? '-'}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {

          },
        );
      }
    );
  }

  static String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
    );
  }
}