import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "title": "Explore Study Materials",
      "subtitle": "Find resources from Algerian universities.",
      "image": "assets/images/books.png",
    },
    {
      "title": "Study Anywhere, Anytime",
      "subtitle": "Check materials from any place at any time.",
      "image": "assets/images/e-course.png",
    },
    {
      "title": "Stay Updated",
      "subtitle": "Get latest study materials.",
      "image": "assets/images/stay_updated.png",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => OnboardingContent(
                title: onboardingData[index]["title"]!,
                subtitle: onboardingData[index]["subtitle"]!,
                image: onboardingData[index]["image"]!,
              ),
            ),
          ),
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => buildDot(index),
            ),
          ),
          const SizedBox(height: 20),
          // Next Button
          ElevatedButton(
            onPressed: () {
              if (_currentPage == onboardingData.length - 1) {
                // Navigate to home screen
                Navigator.pushNamed(context, '/login');
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            child: Text(_currentPage == onboardingData.length - 1
                ? "Get Started"
                : "Next"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, subtitle, image;

  OnboardingContent(
      {required this.title, required this.subtitle, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250),
        const SizedBox(height: 20),
        Text(title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(subtitle,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
