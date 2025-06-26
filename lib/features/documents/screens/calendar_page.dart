import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/particular_model.dart';
import '../models/reminder_model.dart';
import '../../../core/theme.dart';

class CalendarPage extends StatefulWidget {
  final Isar isar;

  const CalendarPage({super.key, required this.isar});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isListView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // Watch for changes in particulars and reminders
    widget.isar.particulars.where().watch(fireImmediately: true).listen((_) {
      _updateEvents();
    });

    widget.isar.reminders.where().watch(fireImmediately: true).listen((_) {
      _updateEvents();
    });
  }

  Future<void> _updateEvents() async {
    final particulars = await widget.isar.particulars.where().findAll();
    final reminders = await widget.isar.reminders.where().findAll();
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    final events = <DateTime, List<CalendarEvent>>{};

    // Add particulars (expiry dates)
    for (final particular in particulars) {
      final date = DateTime(
        particular.expiryDate.year,
        particular.expiryDate.month,
        particular.expiryDate.day,
      );

      final isExpiringSoon = particular.expiryDate.isBefore(thirtyDaysFromNow);
      final title =
          '${particular.title} expires on ${DateFormat('MMM dd, yyyy').format(particular.expiryDate)}';

      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(
        CalendarEvent(
          title: title,
          type: EventType.expiry,
          date: particular.expiryDate,
          particular: particular,
          isExpiringSoon: isExpiringSoon,
        ),
      );
    }

    // Add reminders and recurring reminders
    for (final reminder in reminders) {
      // Get the particular document for this reminder
      final particular = await reminder.particular.value;
      if (particular == null) continue;

      // Add the main reminder
      final reminderDate = DateTime(
        reminder.scheduledDate.year,
        reminder.scheduledDate.month,
        reminder.scheduledDate.day,
      );

      if (events[reminderDate] == null) {
        events[reminderDate] = [];
      }

      events[reminderDate]!.add(
        CalendarEvent(
          title: 'Reminder: ${particular.title}',
          type: EventType.reminder,
          date: reminder.scheduledDate,
          particular: particular,
          isExpiringSoon: false,
          recurrence: reminder.recurrence,
        ),
      );

      // Add recurring reminders if applicable
      if (reminder.recurrence != 'none') {
        final expiryDate = particular.expiryDate;
        var currentDate = reminder.scheduledDate;

        // Calculate start date based on start_days_before
        currentDate = expiryDate.subtract(
          Duration(days: reminder.startDaysBefore),
        );

        while (currentDate.isBefore(expiryDate)) {
          if (reminder.recurrence == 'daily') {
            currentDate = currentDate.add(const Duration(days: 1));
          } else if (reminder.recurrence == 'every_2_days') {
            currentDate = currentDate.add(const Duration(days: 2));
          }

          if (currentDate.isBefore(expiryDate)) {
            final recurringDate = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
            );

            if (events[recurringDate] == null) {
              events[recurringDate] = [];
            }

            events[recurringDate]!.add(
              CalendarEvent(
                title: 'Reminder: ${particular.title}',
                type: EventType.reminder,
                date: currentDate,
                particular: particular,
                isExpiringSoon: false,
                recurrence: reminder.recurrence,
              ),
            );
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _events = events;
        _updateSelectedEvents();
      });
    }
  }

  void _updateSelectedEvents() {
    if (_selectedDay != null) {
      final selectedDate = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      _selectedEvents = _events[selectedDate] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isListView ? _buildListView() : _buildCalendarView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isListView = !_isListView;
          });
        },
        child: Icon(_isListView ? Icons.calendar_month : Icons.list),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              final date = DateTime(day.year, day.month, day.day);
              return _events[date] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _updateSelectedEvents();
              });
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markerMargin: const EdgeInsets.only(top: 4),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: AppTheme.getTextColor(
                  Theme.of(context).brightness == Brightness.dark,
                ),
                fontSize: 10,
              ),
              defaultTextStyle: const TextStyle(fontSize: 10),
              outsideTextStyle: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).primaryColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).primaryColor,
              ),
              titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final events = _events[date] ?? [];
                if (events.isEmpty) return null;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4),
                    ...events
                        .map(
                          (event) => Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  event.type == EventType.expiry
                                      ? AppTheme.getExpiryColor(
                                        event.isExpiringSoon,
                                        Theme.of(context).brightness ==
                                            Brightness.dark,
                                      ).withOpacity(0.1)
                                      : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.type == EventType.expiry
                                  ? '${event.particular?.title} expires'
                                  : 'Reminder${event.recurrence != null && event.recurrence != 'none' ? ' (${event.recurrence})' : ''}',
                              style: TextStyle(
                                fontSize: 8,
                                color:
                                    event.type == EventType.expiry
                                        ? AppTheme.getExpiryColor(
                                          event.isExpiringSoon,
                                          Theme.of(context).brightness ==
                                              Brightness.dark,
                                        )
                                        : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                );
              },
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                return Stack(
                  children: [
                    Positioned(
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${events.length} due',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              _selectedEvents.isEmpty
                  ? Center(
                    child: Text(
                      'No events for selected date',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    event.type == EventType.expiry
                                        ? AppTheme.getExpiryColor(
                                          event.isExpiringSoon,
                                          Theme.of(context).brightness ==
                                              Brightness.dark,
                                        ).withOpacity(0.1)
                                        : Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                event.type == EventType.expiry
                                    ? Icons.event
                                    : Icons.notifications,
                                color:
                                    event.type == EventType.expiry
                                        ? AppTheme.getExpiryColor(
                                          event.isExpiringSoon,
                                          Theme.of(context).brightness ==
                                              Brightness.dark,
                                        )
                                        : Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      height: 1.2,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[200]
                                              : Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('h:mm a').format(event.date),
                                    style: TextStyle(
                                      color: AppTheme.getSecondaryTextColor(
                                        Theme.of(context).brightness ==
                                            Brightness.dark,
                                      ),
                                      fontSize: 11,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (event.type == EventType.expiry &&
                                      event.isExpiringSoon)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.getExpiryColor(
                                            event.isExpiringSoon,
                                            Theme.of(context).brightness ==
                                                Brightness.dark,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Expiring Soon',
                                          style: TextStyle(
                                            color: AppTheme.getExpiryColor(
                                              event.isExpiringSoon,
                                              Theme.of(context).brightness ==
                                                  Brightness.dark,
                                            ),
                                            fontSize: 11,
                                            height: 1.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (event.recurrence != null &&
                                      event.recurrence != 'none')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Recurrence: ${event.recurrence}',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 11,
                                            height: 1.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final allEvents =
        _events.entries.expand((entry) => entry.value).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      itemCount: allEvents.length,
      itemBuilder: (context, index) {
        final event = allEvents[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      event.type == EventType.expiry
                          ? AppTheme.getExpiryColor(
                            event.isExpiringSoon,
                            Theme.of(context).brightness == Brightness.dark,
                          ).withOpacity(0.1)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  event.type == EventType.expiry
                      ? Icons.event
                      : Icons.notifications,
                  color:
                      event.type == EventType.expiry
                          ? AppTheme.getExpiryColor(
                            event.isExpiringSoon,
                            Theme.of(context).brightness == Brightness.dark,
                          )
                          : Theme.of(context).primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[200]
                                : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM dd, yyyy h:mm a').format(event.date),
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(
                          Theme.of(context).brightness == Brightness.dark,
                        ),
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                    if (event.type == EventType.expiry && event.isExpiringSoon)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getExpiryColor(
                              event.isExpiringSoon,
                              Theme.of(context).brightness == Brightness.dark,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Expiring Soon',
                            style: TextStyle(
                              color: AppTheme.getExpiryColor(
                                event.isExpiringSoon,
                                Theme.of(context).brightness == Brightness.dark,
                              ),
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (event.recurrence != null && event.recurrence != 'none')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recurrence: ${event.recurrence}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum EventType { expiry, reminder }

class CalendarEvent {
  final String title;
  final EventType type;
  final DateTime date;
  final Particular? particular;
  final bool isExpiringSoon;
  final String? recurrence;

  CalendarEvent({
    required this.title,
    required this.type,
    required this.date,
    this.particular,
    required this.isExpiringSoon,
    this.recurrence,
  });
}
