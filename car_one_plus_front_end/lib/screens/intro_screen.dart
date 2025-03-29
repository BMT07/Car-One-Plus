import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import 'dart:ui' as ui;

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnimation;
  bool _isButtonHovered = false;

  @override
  void initState() {
    super.initState();

    // Animation pour le bouton
    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _buttonAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    super.dispose();
  }

  Future<void> _checkTokenAndNavigate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _apiService.getToken();

      if (token != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red[800],
          ),
        );
      }
      Navigator.pushReplacementNamed(context, '/login');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  static Future<void> launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir le lien $url'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.red[800],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue : $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final isPortrait = orientation == Orientation.portrait;

    // Adaptation pour écran large ou orientation paysage
    final bottomContainerHeight = isPortrait
        ? screenSize.height * 0.45
        : screenSize.height * 0.7;

    final textSize = isPortrait
        ? screenSize.width * 0.06
        : screenSize.height * 0.05;

    final buttonPadding = isPortrait
        ? EdgeInsets.symmetric(
      vertical: screenSize.height * 0.02,
      horizontal: screenSize.width * 0.15,
    )
        : EdgeInsets.symmetric(
      vertical: screenSize.height * 0.02,
      horizontal: screenSize.width * 0.08,
    );

    final containerPadding = isPortrait
        ? EdgeInsets.symmetric(
      horizontal: screenSize.width * 0.1,
      vertical: screenSize.height * 0.03,
    )
        : EdgeInsets.symmetric(
      horizontal: screenSize.width * 0.06,
      vertical: screenSize.height * 0.04,
    );

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            width: screenSize.width,
            height: screenSize.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image d'arrière-plan avec FadeIn
                Hero(
                  tag: 'background',
                  child: Image.asset(
                    'assets/images/intro_background.png',
                    fit: BoxFit.cover,
                    width: screenSize.width,
                    height: screenSize.height,
                  ),
                ),

                // Conteneur avec effet glassmorphism amélioré
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: bottomContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isPortrait ? 40 : 30),
                        topRight: Radius.circular(isPortrait ? 40 : 30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: BackdropFilter(
                      filter: isPortrait ?
                      ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0) :
                      ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Padding(
                        padding: containerPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Texte principal avec meilleure animation
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0, end: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: child!,
                                  ),
                                );
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.red[900]!,
                                      Colors.red[700]!,
                                      Colors.red[800]!,
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  "LOUEZ LA VOITURE\nDE VOS RÊVES",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    height: 1.3,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 3.0,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isPortrait ? screenSize.height * 0.03 : screenSize.height * 0.04),

                            // Bouton avec animation d'interaction
                            _isLoading
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                            )
                                : MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _isButtonHovered = true;
                                  _buttonAnimController.forward();
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isButtonHovered = false;
                                  _buttonAnimController.reverse();
                                });
                              },
                              child: AnimatedBuilder(
                                animation: _buttonScaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _buttonScaleAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(_isButtonHovered ? 0.4 : 0.2),
                                            blurRadius: _isButtonHovered ? 12 : 8,
                                            spreadRadius: _isButtonHovered ? 2 : 0,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[700],
                                          foregroundColor: Colors.white,
                                          padding: buttonPadding,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: _isButtonHovered ? 8 : 5,
                                        ),
                                        onPressed: _checkTokenAndNavigate,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Commencer',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isPortrait ? screenSize.width * 0.045 : screenSize.height * 0.038,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: isPortrait ? screenSize.width * 0.045 : screenSize.height * 0.038,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: isPortrait ? screenSize.height * 0.02 : screenSize.height * 0.03),

                            // Liens réseaux sociaux améliorés
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1000),
                              tween: Tween(begin: 0, end: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialMediaIcon(
                                    context: context,
                                    icon: FontAwesomeIcons.facebook,
                                    url: 'https://www.facebook.com/share/19tn4GQ4RG/?mibextid=wwXIfr',
                                    color: Colors.blue[900]!,
                                    screenSize: screenSize,
                                    isPortrait: isPortrait,
                                  ),
                                  SizedBox(width: isPortrait ? screenSize.width * 0.05 : screenSize.width * 0.02),
                                  _buildSocialMediaIcon(
                                    context: context,
                                    icon: FontAwesomeIcons.instagram,
                                    url: 'https://www.instagram.com/car_one_plus_?igsh=MXVkejl5c2lyZ3I3cQ==',
                                    color: Colors.pink[600]!,
                                    screenSize: screenSize,
                                    isPortrait: isPortrait,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget amélioré pour les icônes de réseaux sociaux
  Widget _buildSocialMediaIcon({
    required BuildContext context,
    required IconData icon,
    required String url,
    required Color color,
    required Size screenSize,
    required bool isPortrait,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return GestureDetector(
          onTap: () => launchURL(context, url),
          child: MouseRegion(
            onEnter: (_) {
              setState(() {});
            },
            onExit: (_) {
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isPortrait ? 14 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: FaIcon(
                icon,
                color: color,
                size: isPortrait ? screenSize.width * 0.055 : screenSize.height * 0.035,
              ),
            ),
          ),
        );
      },
    );
  }
}