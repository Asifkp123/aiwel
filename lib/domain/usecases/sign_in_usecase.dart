import 'package:dartz/dartz.dart';

import '../../data/repositories/auth_repository.dart';


class Failure {
  final String message;
  Failure(this.message);
}

class OtpRequestSuccess {
  final String response;
  OtpRequestSuccess(this.response);
}
class RequestOtpUseCase {
  final AuthRepository repository;

  RequestOtpUseCase({required this.repository});

  Future<Either<Failure, OtpRequestSuccess>> execute({String? email, String? phoneNumber}) async {
    try {
      Either<Failure, OtpRequestSuccess> response = await repository.requestOtp(
          email: email, phoneNumber: phoneNumber);

      return response.fold(
            (failure) => Left(failure), // Propagate the failure
            (otpSuccess) => Right(otpSuccess), // Pass the OtpRequestSuccess directly
      );
    }catch (e) {
      return Left(Failure('Failed to request OTP: $e'));
    }
  }
}



class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<String> execute(String identifier, String otp) async {
    return await repository.verifyOtp(identifier, otp);
  }
}