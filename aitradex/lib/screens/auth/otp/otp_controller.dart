import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'otp_service.dart';

class OtpController extends GetxController {
  String phone = "";

  //======================================================
  // OTP Controllers
  //======================================================

  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  //======================================================
  // States
  //======================================================

  final RxBool isLoading = false.obs;
  final RxBool canResend = false.obs;
  final RxInt secondsRemaining = 60.obs;

  Timer? _timer;

  // Prevent duplicate verification
  bool _isAutoVerifying = false;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  //======================================================
  // Timer
  //======================================================

  void startTimer() {
    _timer?.cancel();

    secondsRemaining.value = 60;
    canResend.value = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          timer.cancel();
          canResend.value = true;
        }
      },
    );
  }

  //======================================================
  // OTP
  //======================================================

  String get otp =>
      otpControllers.map((e) => e.text.trim()).join();

  bool get isOtpComplete => otp.length == 6;

  //======================================================
  // Auto Verify
  //======================================================

  Future<void> autoVerifyOtp() async {
    if (_isAutoVerifying) return;

    if (!isOtpComplete) return;

    _isAutoVerifying = true;

    final success = await verifyOtp();

    _isAutoVerifying = false;

    if (!success) return;

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    Get.back(result: true);
  }

  //======================================================
  // Verify OTP
  //======================================================

  Future<bool> verifyOtp() async {
    if (!isOtpComplete) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter all 6 digits.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (isLoading.value) {
      return false;
    }

    try {
      isLoading.value = true;

      debugPrint("==================================");
      debugPrint("VERIFY PHONE OTP");
      debugPrint("Phone : $phone");
      debugPrint("OTP   : $otp");

      final result = await OtpService.verifyPhoneOtp(
        phone: phone,
        otp: otp,
      );

      debugPrint(result.toString());

      if (result["success"] == true) {
        Get.snackbar(
          "Success",
          result["message"] ?? "OTP verified successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      }

      Get.snackbar(
        "Verification Failed",
        result["message"] ?? "Invalid OTP.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } catch (e) {
      debugPrint(e.toString());

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  //======================================================
  // Resend OTP
  //======================================================

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    try {
      final result = await OtpService.resendPhoneOtp(
        phone: phone,
      );

      if (result["success"] == true) {
        startTimer();

        for (final c in otpControllers) {
          c.clear();
        }

        focusNodes.first.requestFocus();

        Get.snackbar(
          "Success",
          result["message"] ?? "OTP sent successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Failed",
          result["message"] ?? "Unable to resend OTP.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //======================================================
  // Dispose
  //======================================================

  @override
  void onClose() {
    _timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.onClose();
  }
}