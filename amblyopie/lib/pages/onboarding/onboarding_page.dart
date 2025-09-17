import 'package:amblyopie/pages/onboarding/onboard_content.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = index == 2;
              });
            },
            children: const [
              OnboardContent(
                title: "Suivi personnalisé",
                subtitle: "Crée un profil pour chaque enfant et personnalise les séances selon ses besoins.",
                imagePath: "../../assets/onboarding1.png",
              ),
              OnboardContent(
                title: "Exercices ludiques",
                subtitle: "Des jeux visuels interactifs pour accompagner le traitement de l'amblyopie",
                imagePath: "../../assets/onboarding2.png",
              ),
              OnboardContent(
                title: "Statistiques & Progrès",
                subtitle: "Suis l'évolution de ton enfant à travers des données claires et motivantes.",
                imagePath: "../../assets/onboarding3.png",
              ),
            ],
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                if (onLastPage) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  _controller.nextPage(duration: Duration(microseconds: 500),
                  curve: Curves.ease,
                  );
                }
              },
              child: Text(onLastPage ? "Commencer" : "Suivant"),
            ),
          ),
        ],
      ),
    );
  }
}