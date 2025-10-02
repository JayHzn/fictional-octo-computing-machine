import 'package:flutter/material.dart';
import 'package:amblyopie/models/child.dart';

class ChildHeaderCard extends StatelessWidget {
  final Child child;
  final String ageText;
  final bool isCurrent;

  const ChildHeaderCard({
    super.key,
    required this.child,
    required this.ageText,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(child.firstName.characters.first.toUpperCase()),
          ),
          const SizedBox(height: 8),
          Text(child.firstName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(ageText, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}