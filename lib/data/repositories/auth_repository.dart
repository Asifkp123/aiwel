import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../domain/usecases/sign_in_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, OtpRequestSuccess>> requestOtp({String? email, String? phoneNumber});
  Future<String> verifyOtp(String identifier, String otp);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, OtpRequestSuccess>> requestOtp({String? email, String? phoneNumber}) async {
    try {
      Either<Failure, OtpRequestSuccess> response =await authRemoteDataSource.requestOtp(email: email, phoneNumber: phoneNumber);
      return response.fold(
            (failure) => Left(failure), // Propagate the failure
            (otpSuccess) => Right(otpSuccess), // Pass the OtpRequestSuccess directly
      );    } catch (e) {
      return Left(Failure('Failed to request OTP: $e'));
    }
  }

  @override
  Future<String> verifyOtp(String identifier, String otp) async {
    try {
      final token = await authRemoteDataSource.verifyOtp(identifier, otp);
      await authLocalDataSource.saveToken(token); // Save token locally
      return token;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}