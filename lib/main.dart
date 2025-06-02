import 'package:aiwel/presentation/screens/sign_in_screen.dart';
import 'package:aiwel/presentation/viewmodels/sign_in_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'di/auth_injection.dart';
import 'di/injection.dart';

final getIt = GetIt.instance;

void main() {
  // Setup dependencies using get_it
  setupAuthDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SignInViewModel _signInViewModel;

  @override
  void initState() {
    super.initState();
    // Retrieve the SignInViewModel from get_it
    _signInViewModel = getIt<SignInViewModel>();
  }

  @override
  void dispose() {
    // Dispose of the SignInViewModel to clean up resources
    _signInViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aiwel Sign-In',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignInScreen(viewModelBase: _signInViewModel),
    );
  }
}