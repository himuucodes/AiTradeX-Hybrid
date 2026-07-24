import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../models/signup_model.dart';
import '../../../services/shared_preferences_service.dart';

import '../otp/otp_service.dart';
import 'pages/signup_success_page.dart';

class SignupController extends GetxController {
  // ==========================================================
  // PAGE CONTROLLER
  // ==========================================================

  final PageController pageController = PageController();
  final ImagePicker picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);

  /// Current page index
  final RxInt currentPage = 0.obs;

  /// Total signup pages
  static const int totalPages = 25;

  // ==========================================================
  // SIGNUP MODEL
  // ==========================================================

  /// Holds all signup data
  final Rx<SignupModel> signup = SignupModel().obs;

  // ==========================================================
// TEXT EDITING CONTROLLERS
// ==========================================================

// Personal Details
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();

// Company Details
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();

// PAN & Aadhaar
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController aadhaarNumberController = TextEditingController();

// Address
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

// Bank
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
  TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountHolderNameController =
  TextEditingController();

// Nominee
  final TextEditingController nomineeNameController =
  TextEditingController();

  final TextEditingController nomineeDobController =
  TextEditingController();

// Digital Signature
  final TextEditingController signatureNameController =
  TextEditingController();

// MPIN
  final TextEditingController mpinController = TextEditingController();
  final TextEditingController confirmMpinController =
  TextEditingController();


// ==========================================================
// REACTIVE VARIABLES
// ==========================================================

// Personal
  final RxString selectedGender = "".obs;

// Investment
  final RxString selectedInvestmentGoal = "".obs;
  final RxString selectedInvestmentExperience = "".obs;

// Occupation
  final RxString selectedOccupation = "".obs;

// Income
  final RxString selectedMonthlyIncome = "".obs;

// Bank
  final RxBool isPrimaryBank = true.obs;
  final RxString selectedAccountType = "Savings".obs;

// Nominee
  final RxString selectedNomineeRelation = "".obs;

// Upload Status
  final RxString panImagePath = "".obs;
  final RxString aadhaarFrontImagePath = "".obs;
  final RxString aadhaarBackImagePath = "".obs;
  final RxString selfieImagePath = "".obs;
  final RxString signatureImagePath = "".obs;


// ==========================================================
// VALIDATION
// ==========================================================

  bool get isBankValid {
    return bankNameController.text.isNotEmpty &&
        accountHolderNameController.text.isNotEmpty &&
        accountNumberController.text.isNotEmpty &&
        confirmAccountNumberController.text ==
            accountNumberController.text &&
        ifscController.text.length >= 11;
  }

  bool get isMpinValid {
    return mpinController.text.length == 4 &&
        confirmMpinController.text == mpinController.text;
  }

  bool get isNomineeValid {
    return nomineeNameController.text.isNotEmpty &&
        selectedNomineeRelation.value.isNotEmpty;
  }

  bool get isAddressValid {
    return addressController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        pincodeController.text.length == 6;
  }

  bool get isPanValid {
    return panNumberController.text.length == 10;
  }

  bool get isAadhaarValid {
    return aadhaarNumberController.text.length == 12;
  }

  bool get isNameValid {
    return fullNameController.text.trim().length >= 3;
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  final RxBool isLoading = false.obs;

  Future<void> createAccount() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final success = await submitSignup();

      if (success) {
        await nextPage();
      } else {
        Get.snackbar(
          "Signup Failed",
          "Unable to create your account.",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
  }

  @override
  void onClose() {
    if (pageController.hasClients) {
      pageController.dispose();
    }

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    birthPlaceController.dispose();

    companyNameController.dispose();
    jobTitleController.dispose();

    panNumberController.dispose();
    aadhaarNumberController.dispose();

    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    bankNameController.dispose();
    accountHolderNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();

    nomineeNameController.dispose();
    nomineeDobController.dispose();

    signatureNameController.dispose();

    mpinController.dispose();
    confirmMpinController.dispose();

    super.onClose();
  }

  // ==========================================================
  // PAGE EVENTS
  // ==========================================================

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> nextPage() async {
    if (!pageController.hasClients) return;

    final next = currentPage.value + 1;

    if (next >= 25) return;

    await pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentPage.value = next;
  }

  Future<void> previousPage() async {
    if (!pageController.hasClients) return;

    if (currentPage.value <= 0) return;

    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> goToPage(int page) async {
    if (!pageController.hasClients) return;

    if (page < 0 || page >= totalPages) return;

    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================================================
  // SIGNUP DRAFT
  // ==========================================================

  Future<void> _loadDraft() async {
    try {
      isLoading.value = true;

      final SignupModel? draft =
      await SharedPreferencesService.getSignupData();

      if (draft != null) {
        signup.value = draft;
        fillControllersFromModel();
      }
    } catch (e) {
      debugPrint("Load signup draft error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveDraft() async {
    try {
      await SharedPreferencesService.saveSignupData(
        signup.value,
      );
    } catch (e) {
      debugPrint("Save signup draft error: $e");
    }
  }

  Future<void> clearDraft() async {
    signup.value = SignupModel();

    await SharedPreferencesService.clearSignupData();
  }

  // ==========================================================
// MODEL <-> UI SYNC
// ==========================================================

  /// Read all UI values into the SignupModel
  void updateSignupModel() {
    signup.value
    // Personal Details
      ..fullName = fullNameController.text.trim()
      ..email = emailController.text.trim()
      ..phone = phoneController.text.trim()
      ..countryCode = "+91"
      ..gender = selectedGender.value
      ..dob = dobController.text.trim()
      ..birthPlace = birthPlaceController.text.trim()
      ..profileImage = profileImage.value?.path ?? ""

    // Investment
      ..investmentGoal = selectedInvestmentGoal.value
      ..investmentExperience = selectedInvestmentExperience.value

    // Employment
      ..occupation = selectedOccupation.value
      ..monthlyIncome = selectedMonthlyIncome.value
      ..companyName = companyNameController.text.trim()
      ..jobTitle = jobTitleController.text.trim()

    // PAN & Aadhaar
      ..panNumber = panNumberController.text.trim().toUpperCase()
      ..aadhaarNumber = aadhaarNumberController.text.trim()

    // Uploads
      ..panImageUrl = panImagePath.value
      ..aadhaarFrontUrl = aadhaarFrontImagePath.value
      ..aadhaarBackUrl = aadhaarBackImagePath.value
      ..selfieUrl = selfieImagePath.value

    // Address
      ..address = addressController.text.trim()
      ..city = cityController.text.trim()
      ..state = stateController.text.trim()
      ..pincode = pincodeController.text.trim()

    // Bank
      ..bankName = bankNameController.text.trim()
      ..accountNumber = accountNumberController.text.trim()
      ..accountHolderName = accountHolderNameController.text.trim()
      ..ifscCode = ifscController.text.trim().toUpperCase()
      ..accountType = selectedAccountType.value

    // Nominee
      ..nomineeName = nomineeNameController.text.trim()
      ..nomineeRelation = selectedNomineeRelation.value
      ..nomineeDob = nomineeDobController.text.trim()

    // Signature
      ..signatureUrl = signatureImagePath.value

    // MPIN
      ..mpin = mpinController.text.trim();

    signup.refresh();
  }

  /// Fill all UI controllers from SignupModel
  void fillControllersFromModel() {
    final model = signup.value;

    fullNameController.text = model.fullName;
    emailController.text = model.email;
    phoneController.text = model.phone;
    dobController.text = model.dob;
    birthPlaceController.text = model.birthPlace;

    companyNameController.text = model.companyName;
    jobTitleController.text = model.jobTitle;

    panImagePath.value = model.panImageUrl;
    aadhaarFrontImagePath.value = model.aadhaarFrontUrl;
    aadhaarBackImagePath.value = model.aadhaarBackUrl;
    panNumberController.text = model.panNumber;
    aadhaarNumberController.text = model.aadhaarNumber;

    addressController.text = model.address;
    cityController.text = model.city;
    stateController.text = model.state;
    pincodeController.text = model.pincode;

    bankNameController.text = model.bankName;
    accountNumberController.text = model.accountNumber;
    confirmAccountNumberController.text = model.accountNumber;
    ifscController.text = model.ifscCode;
    selectedAccountType.value = model.accountType;

    nomineeNameController.text = model.nomineeName;

    signatureNameController.text = model.fullName;

    mpinController.text = model.mpin;
    confirmMpinController.text = model.mpin;

    selectedGender.value = model.gender;
    selectedInvestmentGoal.value = model.investmentGoal;
    selectedInvestmentExperience.value = model.investmentExperience;
    selectedOccupation.value = model.occupation;
    selectedMonthlyIncome.value = model.monthlyIncome;
    selectedNomineeRelation.value = model.nomineeRelation;

    selfieImagePath.value = model.selfieUrl;
    signatureImagePath.value = model.signatureUrl;
  }

  /// Save current draft
  Future<void> saveCurrentDraft() async {
    updateSignupModel();
    await saveDraft();
  }

  Future<bool> sendSignupEmailOtp() async {
    try {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        Get.snackbar(
          "Email Required",
          "Please enter your email.",
        );
        return false;
      }

      print("========== SEND OTP ==========");
      print("Email: $email");

      final result = await OtpService.sendOtp(
        email: email,
      );

      print("OTP API Response: $result");

      if (result["success"] == true) {
        print("OTP sent successfully.");
        return true;
      }

      Get.snackbar(
        "Failed",
        result["message"] ?? "Unable to send OTP.",
      );

      return false;
    } catch (e, stackTrace) {
      print("SEND OTP ERROR: $e");
      print(stackTrace);

      Get.snackbar(
        "Error",
        e.toString(),
      );

      return false;
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  // ==========================================================
  // SUBMIT SIGNUP
  // ==========================================================

  final AuthService _authService = AuthService();
  final RxBool isSubmitting = false.obs;

  Future<bool> submitSignup() async {
    try {
      isLoading.value = true;

      // Update latest UI values into the model
      updateSignupModel();

      // Debug: Print request data
      debugPrint("========== SIGNUP REQUEST ==========");
      const encoder = JsonEncoder.withIndent("  ");

      debugPrint(
        encoder.convert(signup.value.toJson()),
      );

      await saveCurrentDraft();
      // Call API
      final result = await _authService.signup(signup.value);

      // Debug: Print response
      debugPrint("========== SIGNUP RESPONSE ==========");
      debugPrint(result.toString());

      if (result["success"] == true &&
          result["data"] != null) {
        final json = result["data"];

        // Save JWT Token
        if (json["token"] != null) {
          await SharedPreferencesService.saveToken(
            json["token"].toString(),
          );
        }

        // Save User ID
        if (json["user"] != null &&
            json["user"]["_id"] != null) {
          await SharedPreferencesService.saveUserId(
            json["user"]["_id"].toString(),
          );
        }

        // Save Login State
        await SharedPreferencesService.setLoggedIn(true);

        // Clear signup draft
        await clearDraft();

        debugPrint("Signup Successful");

        return true;
      }

      debugPrint(
        "Signup Failed: ${result["message"] ?? result["data"]}",
      );

      return false;
    } catch (e, stackTrace) {
      debugPrint("========== SIGNUP ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}