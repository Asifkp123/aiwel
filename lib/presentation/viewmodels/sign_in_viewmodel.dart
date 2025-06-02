import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../domain/usecases/sign_in_usecase.dart';


/// Enum for sign-in status.
enum SignInStatus { idle, loading, otpSent, verifyingOtp, success, error }

/// Encapsulates the state of the sign-in process.
class SignInState {
  final SignInStatus status;
  final String? errorMessage;
  final String? token;

  SignInState({
    required this.status,
    this.errorMessage,
    this.token,
  });

  bool get isLoading => status == SignInStatus.loading || status == SignInStatus.verifyingOtp;
  bool get isOtpSent => status == SignInStatus.otpSent || status == SignInStatus.verifyingOtp || status == SignInStatus.success;
}

/// Abstract interface for the SignInViewModel.
abstract class SignInViewModelBase {
  TextEditingController get emailController;
  TextEditingController get otpController;
  Stream<SignInState> get stateStream;

  void requestOtp();
  void verifyOtp();
  void clearInputs();
  void clearError();
  void dispose();
}

/// ViewModel for the sign-in feature, using streams for state management.
class SignInViewModel implements SignInViewModelBase {
  final RequestOtpUseCase requestOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  // Controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  // StreamController to emit state changes
  final StreamController<SignInState> _stateController = StreamController<SignInState>.broadcast();
  // Current state variables
  SignInStatus _status = SignInStatus.idle;
  String? _errorMessage;
  String? _token;

  SignInViewModel({
    required this.requestOtpUseCase,
    required this.verifyOtpUseCase,
  }) {
    _emitState(); // Emit initial state
  }

  @override
  TextEditingController get emailController => _emailController;

  @override
  TextEditingController get otpController => _otpController;

  @override
  Stream<SignInState> get stateStream => _stateController.stream;

  // Emit the current state to the stream
  void _emitState() {
    _stateController.add(SignInState(
      status: _status,
      errorMessage: _errorMessage,
      token: _token,
    ));
  }

  @override
  Future<Either<Failure, OtpRequestSuccess>> requestOtp() async {
    final identifier = _emailController.text.trim();

    // Validate empty input
    if (identifier.isEmpty) {
      _errorMessage = 'Email or phone number cannot be empty'; // Replace with Strings.emptyEmailMessage
      _status = SignInStatus.error;
      _emitState();
      return Left(Failure(_errorMessage!));
    }

    // Validate email or phone format
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(identifier);
    final isPhone = RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(identifier);
    if (!isEmail && !isPhone) {
      _errorMessage = 'Invalid email or phone number format'; // Replace with Strings.invalidEmailMessage
      _status = SignInStatus.error;
      _emitState();
      return Left(Failure(_errorMessage!));
    }

    // Set loading state
    _status = SignInStatus.loading;
    _errorMessage = null;
    _emitState();

    // Call UseCase and handle Either result
    final result = await requestOtpUseCase.execute(
      email: isEmail ? identifier : null,
      phoneNumber: isPhone ? identifier : null,
    );

    return result.fold(
          (failure) {
        _errorMessage = failure.message; // Replace with Strings.failedOtpRequestMessage
        _status = SignInStatus.error;
        _emitState();
        return Left(failure);
      },
          (success) {
        _status = SignInStatus.otpSent;
        _emitState();
        return Right(success);
      },
    );
  }
  @override
  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      // _errorMessage = Strings.emptyOtpMessage;
      _status = SignInStatus.error;
      _emitState();
      return;
    }

    if (otp.length != 6) {
      // _errorMessage = Strings.invalidOtpMessage;
      _status = SignInStatus.error;
      _emitState();
      return;
    }

    _status = SignInStatus.verifyingOtp;
    _errorMessage = null;
    _emitState();

    try {
      _token = await verifyOtpUseCase.execute(
        _emailController.text.trim(),
        otp,
      );
      _status = SignInStatus.success;
    } catch (e) {
      // _errorMessage = Strings.failedOtpVerificationMessage;
      _status = SignInStatus.error;
    }
    _emitState();
  }

  @override
  void clearInputs() {
    _emailController.clear();
    _otpController.clear();
    _errorMessage = null;
    _token = null;
    _status = SignInStatus.idle;
    _emitState();
  }

  @override
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _emitState();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _stateController.close();
  }




}