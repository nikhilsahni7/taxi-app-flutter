// lib/widgets/otp_verification_widget.dart
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../theme/app_colors.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onVerificationComplete;

  const OtpVerificationWidget({
    super.key,
    required this.phoneNumber,
    required this.onVerificationComplete,
  });

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _timeLeft = 30;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Verify Phone Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the code sent to ${widget.phoneNumber}',
          style: const TextStyle(color: AppColors.caption),
        ),
        const SizedBox(height: 24),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _otpController,
          onChanged: (value) {},
          onCompleted: (value) {
            _verifyOtp(value);
          },
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            activeColor: AppColors.primary,
            selectedColor: AppColors.primary,
            inactiveColor: AppColors.border,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _timeLeft == 0 ? _resendOtp : null,
          child: Text(
            _timeLeft > 0 ? 'Resend code in $_timeLeft seconds' : 'Resend code',
          ),
        ),
      ],
    );
  }

  void _verifyOtp(String otp) async {
    setState(() => _isLoading = true);
    // TODO: Implement actual OTP verification
    await Future.delayed(const Duration(seconds: 2));
    widget.onVerificationComplete(otp);
  }

  void _resendOtp() {
    // TODO: Implement OTP resend
    setState(() => _timeLeft = 30);
  }
}
