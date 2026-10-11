import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/page_dots.dart';
import '../widgets/common/sheet_container.dart';
import 'login_screen.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    image: 'assets/images/onboarding_1.png',
    title: 'Bertani Lebih\nModern & Mudah',
    description: 'Teknologi pintar untuk bantu tingkatkan hasil panen Anda.',
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding_2.png',
    title: 'Pantau Cuaca\n& Risiko Hama',
    description: 'Cek prediksi cuaca dan ancaman hama langsung dari HP.',
  ),
  _OnboardingPage(
    image: 'assets/images/onboarding_3.png',
    title: 'Terhubung dengan\nSesama Petani',
    description: 'Saling berbagi ilmu dan pengalaman dengan petani sekitar.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      Get.off(
        () => const LoginScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 500),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 200,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Image.asset(
                _pages[i].image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SheetContainer(
              shadow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: Column(
                      key: ValueKey(_index),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(page.title, style: AppText.heading()),
                        const SizedBox(height: AppSpace.lg),
                        Text(page.description, style: AppText.body()),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  PageDots(count: _pages.length, index: _index),
                  const SizedBox(height: AppSpace.xl),
                  AppButton(
                    label: _isLast ? 'Mulai Sekarang' : 'Lanjut',
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
