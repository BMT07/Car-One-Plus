import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_choice_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/address_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/car_details_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/user_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/reservation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context)=>VehicleProvider()),
        ChangeNotifierProvider(create: (context)=>ReservationProvider()),

      ],
      child: MyApp(),
    ),
  );
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarOnePlus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/intro': (context) => IntroScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/userChoice': (context) => UserChoiceScreen(),
        '/home': (context) => HomeScreen(),
        '/reservations': (context) => ReservationScreen(),
        '/profile': (context) => ProfileScreen(),
        '/address': (context) => AddressScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
        //'/carDetails': (context)=> CarDetailsScreen(car: car),
        '/main': (context) => MainScreen(), // Nouvelle route pour la navigation avec le BottomNavigationBar
      },
    );
  }
}
