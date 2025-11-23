import 'package:flutter/material.dart';
import 'package:amblyopie/pages/guide/guide_details_page.dart';

class GuideStep {
  final String image;
  final List<String> detailImages;

  const GuideStep({
    required this.image,
    this.detailImages = const [], 
  });

  bool get hasDetails => detailImages.isNotEmpty;
}

class GuideViewerPage extends StatefulWidget {
  const GuideViewerPage({super.key});

  @override
  State<GuideViewerPage> createState() => _GuideViewerPageState();
}

class _GuideViewerPageState extends State<GuideViewerPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<GuideStep> _steps = const [
    GuideStep(
      image: 'assets/guide/guide_2.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_3.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_4.png',
      detailImages: [
        'assets/guide/guide_5.png',
      ],
    ),
    GuideStep(
      image: 'assets/guide/guide_6.png',
      detailImages: [
        'assets/guide/guide_7.png',
      ],
    ),
    GuideStep(
      image: 'assets/guide/guide_8.png',
      detailImages: [
        'assets/guide/guide_9.png',
      ],
    ),
    GuideStep(
      image: 'assets/guide/guide_10.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_11.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_12.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_13.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_14.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_15.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_16.png'
    ),
    GuideStep(
      image: 'assets/guide/guide_17.png'
    ),
  ];

  GuideStep get _currentStep => _steps[_currentIndex];

  void _next() {
    if (_currentIndex < _steps.length -1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _openMore() {
    if (!_currentStep.hasDetails) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuideDetailsPage(
          detailImages: _currentStep.detailImages,
        )
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentIndex == _steps.length - 1;
    final bool hasDetails = _currentStep.hasDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final step = _steps[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0, // zoom ×4
                      child: Image.asset(
                        step.image,
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
            children: List.generate(_steps.length, (i) {
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
                )
              );
            }),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasDetails)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _openMore,
                      child: const Text('En savoir plus'),
                    ),
                  ),
                if (hasDetails) const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _next,
                    child: Text(isLast ? 'Terminer' : 'Suivant'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}