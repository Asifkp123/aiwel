  import 'dart:convert';
  import 'package:dartz/dartz.dart';
  import 'package:http/http.dart' as http;
  
  import '../../../core/config/api_config.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
  
  class AuthRemoteDataSource {
    // Initiates login by sending OTP to the provided email or phone number
      Future<Either<Failure, OtpRequestSuccess>> requestOtp({String? email, String? phoneNumber}) async {
  print(email);
  print("email");

  final payload = email != null ? {'email': email} : {'phone_number': phoneNumber};
  print('Request OTP Payload: ${jsonEncode(payload)}');
  print('Headers: ${ApiConfig.defaultHeaders}');

  final response = await http.post(
    Uri.parse("https://api.aiwel.org/api/v1/login_with_otp"), // Use HTTPS
    body: jsonEncode(payload),
    headers: ApiConfig.defaultHeaders,
  ).timeout(Duration(seconds: 30), onTimeout: () {
    return http.Response('Request timed out', 408);
  });


      if (response.statusCode != 200) {
        print(response.statusCode);
        print("response.statusCod");
        return Left(Failure('Failed to request OTP: ${response.statusCode} - ${response.reasonPhrase}'));
      }

      return Right(OtpRequestSuccess(response.body));

    }

    // Verifies the OTP for the given identifier (email or phone number)
    Future<String> verifyOtp(String identifier, String otp) async {
      final payload = {
        'identifier': identifier,
        'otp': otp,
      };
  
      final response = await http.post(
        Uri.parse('https://api.aiwel.org/api/v1/verify_otp'),
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
  
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Assuming the API returns a token
      } else {
        throw Exception('Failed to verify OTP: ${response.reasonPhrase}');
      }
    }
  }