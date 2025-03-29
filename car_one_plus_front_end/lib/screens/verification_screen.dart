import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import 'change_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  int _resendCooldown = 0;

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60; // 60 secondes de cooldown
    });

    // Décompte du temps restant
    Stream.periodic(const Duration(seconds: 1), (x) => 60 - x - 1)
        .take(60)
        .listen((remainingTime) {
      setState(() {
        _resendCooldown = remainingTime;
      });
    });
  }

  Future<void> _resendVerificationCode() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.requestPasswordReset(widget.email);

      if (response['success']) {
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code renvoyé avec succès !', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Erreur lors du renvoi du code', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyCode() async {
    final code = _otpController.text.trim();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez entrer un code à 6 chiffres"),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.verifyResetCode(code);

      if (response.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["error"], style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      } else {
        final userId = response["user_id"];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(userId: userId),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Code vérifié avec succès !", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialisation de flutter_screenutil pour le responsive design
    return ScreenUtilInit(
      //context,
      designSize: const Size(375, 812), // Taille de design de base (iPhone X)
      //minTextAdaptationFactor: 1.2,
      splitScreenMode: true,
      builder: (context, child){
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Fermer le clavier en tapant en dehors
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),

                    // Bouton de retour intégré
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Vérification",
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      "Nous avons envoyé un code à 6 chiffres à votre adresse e-mail.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700]
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Code envoyé à ${widget.email}",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Champs OTP amélioré
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.scale,
                      textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10.r),
                        fieldHeight: 50.h,
                        fieldWidth: 40.w,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.grey.shade100,
                        selectedFillColor: Colors.red.shade50,
                        inactiveColor: Colors.grey.shade300,
                        activeColor: Colors.red,
                        selectedColor: Colors.red.shade700,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                      onCompleted: (_) => _verifyCode(), // Vérification automatique quand 6 chiffres
                    ),

                    SizedBox(height: 30.h),

                    // Bouton de vérification dynamique
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isLoading ? 60.w : 300.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: _isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.w,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Vérifier",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Option de renvoi de code avec cooldown
                    TextButton(
                      onPressed: _resendCooldown > 0 ? null : _resendVerificationCode,
                      child: Text(
                        _resendCooldown > 0
                            ? "Renvoyer dans $_resendCooldown sec"
                            : "Vous n'avez pas reçu le code ? Renvoyer",
                        style: TextStyle(
                            color: _resendCooldown > 0 ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );


  }
}