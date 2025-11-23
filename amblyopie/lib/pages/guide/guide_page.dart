import 'package:flutter/material.dart';
import 'package:amblyopie/pages/guide/guide_viewer_page.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GuideViewerPage()),
            );
          },
          child: const Text("Ouvrir le guide"),
        ),
      ),
    );
  }
}
