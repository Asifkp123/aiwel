import 'package:flutter/material.dart';
import '../viewmodels/sign_in_viewmodel.dart';

/// Screen for OTP-based sign-in.
class SignInScreen extends StatelessWidget {
  final SignInViewModelBase viewModelBase;

  const SignInScreen({Key? key, required this.viewModelBase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: StreamBuilder<SignInState>(
            stream: viewModelBase.stateStream,
            initialData: SignInState(status: SignInStatus.idle),
            builder: (context, snapshot) {
              final state = snapshot.data!;
              final isLoading = state.isLoading;
              final isOtpSent = state.isOtpSent;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple[100],
                      ),
                      child: const Center(
                        child: Text(
                          "Aiwel",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          semanticsLabel: "Aiwel",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome to Aiwel",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Experience secure and seamless authentication",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: viewModelBase.emailController,
                      onChanged: (value) => viewModelBase.clearError(),
                      decoration: InputDecoration(
                        labelText: "Email or Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: state.errorMessage != null && !isOtpSent
                            ? state.errorMessage
                            : null,
                      ),
                      enabled: !isOtpSent,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    if (isOtpSent) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: viewModelBase.otpController,
                              onChanged: (value) => viewModelBase.clearError(),
                              decoration: InputDecoration(
                                labelText: "Enter 6-digit OTP",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                errorText: state.errorMessage != null
                                    ? state.errorMessage
                                    : null,
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                               viewModelBase.requestOtp();
                              if (state.errorMessage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("OTP resent successfully")),
                                );
                              }
                            },
                            child: const Text(
                              "Resend OTP",
                              style: TextStyle(color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                          if (!isOtpSent) {
                             viewModelBase.requestOtp();
                            if (state.errorMessage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("OTP sent successfully")),
                              );
                            }
                          } else {
                             viewModelBase.
                            verifyOtp();
                            if (state.status == SignInStatus.success) {
                              viewModelBase.clearInputs();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Sign-in successful!")),
                              );
                            }
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isOtpSent ? "Verify & Continue" : "Request OTP"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("or continue with"),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _SocialIconButton(icon: Icons.g_mobiledata),
                        _SocialIconButton(icon: Icons.apple),
                        _SocialIconButton(icon: Icons.facebook),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          "Protected by end-to-end encryption",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;

  const _SocialIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 20,
      child: Icon(icon, size: 24, color: Colors.black87),
    );
  }
}