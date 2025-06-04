import 'package:AXMPAY/main.dart';
import 'package:AXMPAY/ui/screens/login_page.dart';
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
  late AnimationController _backgroundController;
  late AnimationController _bezierController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPulseAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _bezierAnimation;

  final List<Color> _gradientColors = [
    Color(0xFF3B1E96),  // Darker bluish-purple
    Color(0xFF462EB4),  // Base color (bluish-purple)
    Color(0xFF6243D6),  // Slightly lighter bluish-purple
    Color(0xFF7857E9),  // Bright violet
  ];

  final String _text = 'FustPay';
  String _animatedText = '';
  List<Color> _currentGradient = [];
  double _backgroundRotation = 0.0;
  bool _hasNavigated = false; // Prevent multiple navigation calls

  @override
  void initState() {
    super.initState();
    _currentGradient = [..._gradientColors];
    _setupAnimations();
    _startNavigationTimer();
  }

  void _setupAnimations() {
    _setupMainAnimation();
    _setupLogoAnimation();
    _setupTextAnimation();
    _setupBackgroundAnimation();
    _setupBezierAnimation();
  }

  void _startNavigationTimer() {
    // Navigate to login page after splash duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_hasNavigated) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Stop all repeating animations before navigation
    _backgroundController.stop();
    _bezierController.stop();
    _logoController.stop();

    // Use GoRouter navigation instead of Navigator
    // Replace '/login' with your actual login route path
    context.go('/login');

    // Alternative: If you need to replace the current route completely
    // context.pushReplacement('/login');
  }

  void _setupBezierAnimation() {
    _bezierController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _bezierAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bezierController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _bezierController.forward().then((_) {
      if (mounted && !_hasNavigated) {
        _bezierController.repeat(reverse: true);
      }
    });
  }

  void _setupMainAnimation() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
        curve: Interval(0.4, 0.7, curve: Curves.easeInOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
  }

  void _setupLogoAnimation() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.5, 1.0),
      ),
    );

    _logoController.forward().then((_) {
      if (mounted && !_hasNavigated) {
        _logoController.repeat(reverse: true);
      }
    });
  }

  void _setupTextAnimation() {
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textController.addListener(() {
      if (mounted) {
        setState(() {
          final progress = (_text.length * _textController.value).round();
          _animatedText = _text.substring(0, progress);
        });
      }
    });

    // Start text animation after main animation completes
    _mainController.forward().then((_) {
      if (mounted && !_hasNavigated) {
        _textController.forward();
      }
    });
  }

  void _setupBackgroundAnimation() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _backgroundAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _backgroundController.addListener(() {
      if (mounted) {
        setState(() {
          _backgroundRotation = _backgroundAnimation.value;
        });
      }
    });

    _backgroundController.forward().then((_) {
      if (mounted && !_hasNavigated) {
        _backgroundController.repeat();
      }
    });
  }

  Path _createBezierPath(Size size) {
    var path = Path();
    var w = size.width;
    var h = size.height;

    double bezierValue = _bezierAnimation.value;

    path.moveTo(0, 0);
    path.quadraticBezierTo(
        w * (0.3 + 0.1 * math.sin(bezierValue * math.pi)),
        h * (0.2 + 0.1 * math.cos(bezierValue * math.pi)),
        w * 0.5,
        h * 0.5
    );
    path.quadraticBezierTo(
        w * (0.7 - 0.1 * math.sin(bezierValue * math.pi)),
        h * (0.8 - 0.1 * math.cos(bezierValue * math.pi)),
        w,
        h
    );
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _bezierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button from working on splash screen
      child: Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _logoController,
            _textController,
            _backgroundController,
            _bezierController
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _currentGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      transform: GradientRotation(_backgroundRotation),
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height),
                  painter: BezierPainter(
                    _createBezierPath(MediaQuery.of(context).size),
                    Color(0xFF9D50BB).withOpacity(0.3),
                  ),
                ),
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: _logoScaleAnimation.value *
                                  _logoPulseAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 25,
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: SvgIcon(
                                      "assets/images/axmpay_logo.svg",
                                      color: Colors.white,
                                      width: 85.w,
                                      height: 75.h,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [Colors.white, Colors.white70],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                _animatedText,
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(4, 4),
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: Colors.white.withOpacity(0.3),
                                      offset: Offset(-2, -2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BezierPainter extends CustomPainter {
  final Path path;
  final Color color;

  BezierPainter(this.path, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}