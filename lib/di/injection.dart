import 'package:get_it/get_it.dart';
import 'auth_injection.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  setupAuthDependencies();
  // Add more feature setups as needed
}