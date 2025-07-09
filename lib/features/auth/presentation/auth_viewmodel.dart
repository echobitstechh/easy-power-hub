import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class AuthViewModel extends BaseViewModel {
  final _navService = locator<NavigationService>();

  // Page index: 0 - Register, 1 - Login, 2 - OTP
  int currentIndex = 0;

  final formKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();


  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  bool passwordVisible = false;


  bool isRegistering = false;
  bool isLoggingIn = false;
  bool isVerifyingOtp = false;
  bool isGoogleLoading = false;


  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void init({required TickerProvider vsync}) {

  }

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    notifyListeners();
  }

  void flipForward() {
    if (currentIndex < 2) {
      currentIndex++;
      notifyListeners();
    }
  }

  void flipBackward() {
    if (currentIndex > 0) {
      currentIndex--;
      notifyListeners();
    }
  }

  void goToRegister() {
    currentIndex = 0;
    notifyListeners();
  }

  void goToLogin() {
    currentIndex = 1;
    notifyListeners();
  }

  void goToOtp() {
    currentIndex = 2;
    notifyListeners();
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    isRegistering = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // simulate API call
    isRegistering = false;
    goToOtp();
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoggingIn = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    isLoggingIn = false;
    goToOtp();
  }

  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;
    isVerifyingOtp = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    isVerifyingOtp = false;
    _navService.clearStackAndShow(Routes.homeView);
  }

  void resendOtp() {
    // Trigger resend
    debugPrint('🔁 Resend OTP tapped');
  }

  Future<void> googleSignIn() async {
    isGoogleLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    isGoogleLoading = false;
    goToOtp();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    for (var ctrl in otpControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }
}
