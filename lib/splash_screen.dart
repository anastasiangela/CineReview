import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;

  late AnimationController _fadeSlideController;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _fadeText;

  late AnimationController _shimmerController;

  List<Star> stars = [];

  @override
  void initState() {
    super.initState();

    _generateStars();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOut),
    );

    _fadeText = CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeIn,
    );

    _logoController.forward().then((_) => _fadeSlideController.forward());

    _checkAuthStatus();
  }

  void _generateStars() {
    final random = Random();
    for (int i = 0; i < 80; i++) {
      stars.add(
        Star(
          position: Offset(
            random.nextDouble() * 500,
            random.nextDouble() * 800,
          ),
          radius: random.nextDouble() * 2,
          opacity: random.nextDouble(),
        ),
      );
    }
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeSlideController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: StarBackgroundPainter(stars),
            child: Container(),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [Colors.cyanAccent, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                _shimmerController.value - 0.3,
                                _shimmerController.value,
                              ],
                            ).createShader(bounds);
                          },
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _fadeText,
                    child: ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [Colors.cyanAccent, Colors.blueAccent],
                          ).createShader(bounds),
                      child: const Text(
                        'CineReview',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _fadeText,
                      child: const Text(
                        'Discover & Review Your Favorite Films',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeText,
                    child: const CircularProgressIndicator(
                      color: Colors.cyanAccent,
                    ),
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

class Star {
  Offset position;
  double radius;
  double opacity;

  Star({required this.position, required this.radius, required this.opacity});
}

class StarBackgroundPainter extends CustomPainter {
  final List<Star> stars;

  StarBackgroundPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      paint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(star.position, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
