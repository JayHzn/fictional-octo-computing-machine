import 'package:flutter/material.dart';

class GuideDetailsPage extends StatefulWidget {
  final List<String> detailImages;

  const GuideDetailsPage({
    super.key,
    required this.detailImages,
  });

  @override
  State<GuideDetailsPage> createState() => _GuideDetailsPageState();
}

class _GuideDetailsPageState extends State<GuideDetailsPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _images => widget.detailImages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _images.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0, // zoom ×4
                      child: Image.asset(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (i) {
              final isActive = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _next,
                child: Text(isLast ? 'Fermer' : 'Suivant'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
