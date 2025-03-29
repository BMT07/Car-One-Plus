import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service.dart';
import 'main_screen.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;

  bool _obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Fermer le clavier
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await apiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.containsKey("error")) {
        setState(() {
          errorMessage = response["error"];
          isLoading = false;
        });
        _animationController.forward().then((_) => _animationController.reverse());
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response["access_token"]);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateUserData();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
        isLoading = false;
      });
      _animationController.forward().then((_) => _animationController.reverse());
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Adapter les tailles selon l'orientation
    final double logoSize = isLandscape
        ? screenHeight * 0.25
        : screenWidth * 0.25;

    final double titleSize = isLandscape
        ? screenHeight * 0.05
        : screenWidth * 0.06;

    final double subtitleSize = isLandscape
        ? screenHeight * 0.03
        : screenWidth * 0.04;

    final double buttonHeight = isLandscape
        ? screenHeight * 0.08
        : screenHeight * 0.06;

    return GestureDetector(
      // Fermer le clavier quand on touche l'écran
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return isLandscape
                  ? _buildLandscapeLayout(
                  screenWidth,
                  screenHeight,
                  logoSize,
                  titleSize,
                  subtitleSize,
                  buttonHeight
              )
                  : _buildPortraitLayout(
                  screenWidth,
                  screenHeight,
                  logoSize,
                  titleSize,
                  subtitleSize,
                  buttonHeight
              );
            },
          ),
        ),
      ),
    );
  }

  // Layout pour l'orientation portrait
  Widget _buildPortraitLayout(
      double screenWidth,
      double screenHeight,
      double logoSize,
      double titleSize,
      double subtitleSize,
      double buttonHeight
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // Logo animé
                    Center(
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ).animate().fadeIn(duration: 600.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 800.ms,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Titre avec animation
                    Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutQuad,
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    // Sous-titre avec animation
                    Text(
                      'Bienvenue, connectez-vous pour continuer',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: 800.ms,
                      delay: 300.ms,
                      curve: Curves.easeIn,
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Champ email
                    _buildAnimatedInput(
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: _inputDecoration(
                          labelText: 'Email',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      delay: 400.ms,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Champ mot de passe
                    _buildAnimatedInput(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: _inputDecoration(
                          labelText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      delay: 600.ms,
                    ),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotPassword');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontSize: subtitleSize * 0.9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Message d'erreur avec animation
                    if (errorMessage != null)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              10 * sin(_animationController.value * 6 * 3.14159),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: subtitleSize * 0.9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.03),

                    // Bouton de connexion
                    _buildAnimatedInput(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red[300],
                          elevation: 2,
                          shadowColor: Colors.red.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : Text(
                          'Se Connecter',
                          style: TextStyle(
                            fontSize: subtitleSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      delay: 800.ms,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Connexion invité
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/main');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                        child: Text(
                          'Continuer en tant qu\'invité',
                          style: TextStyle(
                            fontSize: subtitleSize * 0.9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Lien d'inscription
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Pas de compte ? ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: subtitleSize * 0.9,
                          ),
                          children: [
                            TextSpan(
                              text: "Inscrivez-vous",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/register');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Layout pour l'orientation paysage
  Widget _buildLandscapeLayout(
      double screenWidth,
      double screenHeight,
      double logoSize,
      double titleSize,
      double subtitleSize,
      double buttonHeight
      ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.02,
        ),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section gauche - Logo et titre
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ).animate().fadeIn(duration: 600.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 500.ms,
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    Text(
                      'Bienvenue, connectez-vous pour continuer',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: 800.ms,
                      delay: 300.ms,
                    ),
                  ],
                ),
              ),

              // Séparateur vertical
              Container(
                height: screenHeight * 0.6,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),

              // Section droite - Formulaire
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Champ email
                    _buildAnimatedInput(
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: _inputDecoration(
                          labelText: 'Email',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      delay: 400.ms,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Champ mot de passe
                    _buildAnimatedInput(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: _inputDecoration(
                          labelText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      delay: 600.ms,
                    ),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotPassword');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontSize: subtitleSize * 0.9,
                          ),
                        ),
                      ),
                    ),

                    // Message d'erreur
                    if (errorMessage != null)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              10 * sin(_animationController.value * 6 * 3.14159),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: subtitleSize * 0.9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.02),

                    // Bouton de connexion
                    _buildAnimatedInput(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red[300],
                          elevation: 2,
                          shadowColor: Colors.red.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : Text(
                          'Se Connecter',
                          style: TextStyle(
                            fontSize: subtitleSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      delay: 800.ms,
                    ),

                    // Ligne avec options supplémentaires
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Connexion invité
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/main');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[700],
                          ),
                          child: Text(
                            'Continuer en tant qu\'invité',
                            style: TextStyle(
                              fontSize: subtitleSize * 0.8,
                            ),
                          ),
                        ),

                        // Lien d'inscription
                        RichText(
                          text: TextSpan(
                            text: "Pas de compte ? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: subtitleSize * 0.8,
                            ),
                            children: [
                              TextSpan(
                                text: "Inscrivez-vous",
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper pour les animations des entrées de formulaire
  Widget _buildAnimatedInput({
    required Widget child,
    required Duration delay,
  }) {
    return child.animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: delay, curve: Curves.easeOutQuad);
  }

  // Helper pour la décoration des champs de texte
  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[700]!, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}