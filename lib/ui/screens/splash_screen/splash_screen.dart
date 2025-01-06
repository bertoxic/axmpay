import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../../widgets/svg_maker/svg_icon.dart';

class FustPaySplashScreen extends StatefulWidget {
  const FustPaySplashScreen({Key? key}) : super(key: key);

  @override
  _FustPaySplashScreenState createState() => _FustPaySplashScreenState();
}

class _FustPaySplashScreenState extends State<FustPaySplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPulseAnimation;

  final String _text = 'FustPay';
  String _animatedText = '';

  @override
  void initState() {
    super.initState();
    _setupMainAnimation();
    _setupLogoAnimation();
    _setupTextAnimation();

    Future.delayed(const Duration(seconds: 5), () {
      context.go('/login');
    });
  }

  void _setupMainAnimation() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.5, 0.75, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
  }

  void _setupLogoAnimation() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    _logoController.forward();
  }

  void _setupTextAnimation() {
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textController.addListener(() {
      setState(() {
        final progress = (_text.length * _textController.value).round();
        _animatedText = _text.substring(0, progress);
      });
    });

    _mainController.forward().then((_) {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_mainController, _logoController, _textController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _logoScaleAnimation.value * _logoPulseAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgIcon(
                              "assets/images/axmpay_logo.svg",
                              color: colorScheme.primary,
                              width: 63.w,
                              height: 53.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        _animatedText,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}