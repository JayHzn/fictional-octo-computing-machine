import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:amblyopie/models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Color color;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onColor = Colors.white;

    final dateStr = DateFormat("EEEE d MMMM", "fr_FR").format(appointment.date);
    final hourStr = DateFormat("HH:mm", "fr_FR").format(appointment.date);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_information_outlined,
                    color: onColor.withOpacity(0.95), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.title,
                      style: TextStyle(
                        color: onColor,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _Chip(
                    icon: Icons.access_time,
                    label: hourStr,
                    onColor: onColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                dateStr,
                style: TextStyle(
                  color: onColor.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (appointment.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  appointment.subtitle!,
                  style: TextStyle(
                    color: onColor.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color onColor;

  const _Chip({
    required this.icon,
    required this.label,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(children: [
        Icon(icon, color: onColor, size: 16),
        const SizedBox(width: 6),
        Text(label,
          style: TextStyle(color: onColor, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}