import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aitradex/core/widgets/primary_button.dart';

import '../../signup/signup_controller.dart';
import '../otp_controller.dart';

class ConfirmButton extends GetView<OtpController> {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => PrimaryButton(
        text: controller.isLoading.value
            ? "Verifying..."
            : "Confirm OTP",
             enabled: !controller.isLoading.value,
            onPressed: () async {
              if (controller.isLoading.value) return;

              final success = await controller.verifyOtp();

              if (!success) return;

              // Return success to PhoneNumberPage
              Get.back(result: true);
            },
      ),
    );
  }
}