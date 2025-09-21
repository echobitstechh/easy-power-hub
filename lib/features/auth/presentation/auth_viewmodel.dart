import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/profile.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import 'auth_service.dart';
import 'auth_view.dart';

enum RegistrationResult { success, failure }

class AuthViewModel extends BaseViewModel {
  final _log = getLogger("AuthViewModel");
  final _repo = locator<Repository>();
  final _snackBar = locator<SnackbarService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _localStorage = locator<LocalStorage>();

  // Page Navigation State
  PresentPage _presentPage = PresentPage.login;
  PresentPage get presentPage => _presentPage;
  void setPresentPage(PresentPage page) {
    _presentPage = page;
    notifyListeners();
  }

  // Text Controllers & UI State
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final cPassword = TextEditingController();
  final otp = TextEditingController();
  final initialEmail = TextEditingController();
  final inputController = TextEditingController();


  final ValueNotifier<bool> _isPhoneNumberNotifier = ValueNotifier(false);
  ValueNotifier<bool> get isPhoneNumberNotifier => _isPhoneNumberNotifier;

  void onEmailOrPhoneChanged(String value) {
    final bool isPhone = value.isNotEmpty && RegExp(r'^\d').hasMatch(value);
    _isPhoneNumberNotifier.value = isPhone;
  }

  bool get isPhoneNumber => _isPhoneNumberNotifier.value;


  bool _obscure = true;
  bool get obscure => _obscure;
  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  bool _isOtpRequested = false;
  bool get isOtpRequested => _isOtpRequested;
  set isOtpRequested(bool value) {
    _isOtpRequested = value;
    notifyListeners();
  }

  final bool _isLoginByEmail = true;
  bool get isLoginByEmail => _isLoginByEmail;




  // Method to handle initial parameters from navigation
  void setParameters(Map<String, dynamic> params) {
    isOtpRequested = params['isOtpRequested'] == 'true';
    if (params['phone'] != null) phone.text = params['phone'];
    if (params['email'] != null) email.text = params['email'];
  }

  // In AuthViewModel
  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one digit';
    if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) return 'Password must contain at least one special character';
    return null;
  }

  String? validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Password confirmation is required';
    if (value != password.text) return 'Passwords do not match';
    return null;
  }

  // --- Core Logic ---

  Future<void> init() async {
    String? token = await _localStorage.fetch(LocalStorageDir.authToken);
    if (token != null && !JwtDecoder.isExpired(token)) {
      userLoggedIn.value = true;
      String? userJson = await _localStorage.fetch(LocalStorageDir.authUser);
      if (userJson != null) {
        profile.value = Profile.fromJson(jsonDecode(userJson));
      }
      _navigationService.clearStackAndShow(Routes.homeView);
    }
  }

  Future<void> login() async {
    setBusy(true);

    try {
      if (phone.text.isNotEmpty && !phone.text.startsWith('0')) {
        phone.text = '0${phone.text}';
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      final requestBody = {
        if (inputController.text.contains('@')) "email": inputController.text,
        if (RegExp(r'^\d').hasMatch(inputController.text)) "phoneNumber": inputController.text,
        // if (email.text.isNotEmpty) "email": email.text,
        // if (phone.text.isNotEmpty) "phoneNumber": phone.text,
        "password": password.text,
        "fcmToken": fcmToken,
      };

      ApiResponse res = await _repo.login(requestBody);

      if (res.statusCode == 200) {
        final data = res.data;
        if (data['verificationRequired'] == true) {
          _handleVerificationFlow(data);
        } else if (data['incompleteBiodata'] == true) {
          _handleIncompleteProfileFlow(data);
        } else {
          _handleSuccessfulLogin(data);
        }
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "An error occurred during login.");
      }
    } catch (e) {
      _log.e("Login error: $e");
      _snackBar.showSnackbar(message: "Unable to login. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  Future<void> register() async {
    setBusy(true);
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      ApiResponse res = await _repo.register({
        "firstName": firstname.text,
        "lastName": lastname.text,
        "email": email.text,
        "phoneNumber": phone.text,
        "password": password.text,
        "fcmToken": fcmToken,
      });

      if (res.statusCode == 200) {
        _handleSuccessfulLogin(res.data);
        _snackBar.showSnackbar(message: res.data["message"]);
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Registration failed.");
      }
    } catch (e) {
      _log.e("Registration error: $e");
      _snackBar.showSnackbar(message: "Registration failed. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  Future<void> submitOtp() async {
    setBusy(true);
    try {
      ApiResponse res = await _repo.submitOtp({
        "userId": profile.value.id,
        "verificationCode": otp.text,
        "vRef": profile.value.reference,
      });

      if (res.statusCode == 200) {
        _snackBar.showSnackbar(message: 'OTP verified successfully');
        _navigationService.navigateTo(
          Routes.authView,
          arguments: AuthViewArguments(initialPage: PresentPage.register),
        );
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? 'Verification failed');
      }
    } catch (e) {
      _log.e("OTP submission error: $e");
      _snackBar.showSnackbar(message: 'An error occurred. Please try again later.');
    } finally {
      setBusy(false);
    }
  }

  Future<void> requestOtp() async {
    setBusy(true);
    try {
      if (phone.text.isNotEmpty && !phone.text.startsWith('0')) {
        phone.text = '0${phone.text}';
      }

      ApiResponse res = await _repo.requestOtp({
        if (email.text.isNotEmpty) "email": email.text,
        if (phone.text.isNotEmpty) "phoneNumber": phone.text,
      });

      if (res.statusCode == 200) {
        profile.value.id = res.data['data']["userId"];
        profile.value.email = email.text;
        if (phone.text.isNotEmpty) {
          profile.value.phoneNumber = phone.text;
          profile.value.reference = res.data['data']["sendTokenResponse"]["data"]["reference"];
        }
        isOtpRequested = true;
        _snackBar.showSnackbar(message: 'OTP sent successfully');
      } else {
        _snackBar.showSnackbar(message: res.data['message'] ?? 'An unexpected error occurred');
      }
    } catch (e) {
      _log.e('Request OTP unhandled error: $e');
      _snackBar.showSnackbar(message: 'An unexpected error occurred');
    } finally {
      setBusy(false);
    }
  }

  Future<void> signInWithGoogle() async {
    setBusy(true);
    try {
      final googleSignInResult = await _authService.signInWithGoogle();
      if (googleSignInResult == null) {
        _snackBar.showSnackbar(message: "Google Sign-In was cancelled", duration: const Duration(seconds: 2));
        return;
      }

      final isNewUser = googleSignInResult['isNewUser'] as bool?;
      String? phoneNumber = googleSignInResult['phoneNumber'] as String?;
      final email = googleSignInResult['email'] as String?;
      final idToken = googleSignInResult['idToken'] as String?;
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (idToken == null || email == null) {
        _snackBar.showSnackbar(message: "Failed to retrieve account info", duration: const Duration(seconds: 2));
        return;
      }


      if (isNewUser == true && (phoneNumber == null || phoneNumber.isEmpty)) {
        final dialogService = locator<DialogService>();
        final response = await dialogService.showCustomDialog(
          variant: DialogType.phoneInput,
          title: 'Enter Phone Number',
          description: 'A phone number is required for new accounts.',
          mainButtonTitle: 'Submit',
          secondaryButtonTitle: 'Cancel',
        );

        if (response?.confirmed == true && response?.data is String) {
          phoneNumber = response?.data;
        } else {
          _snackBar.showSnackbar(message: "Phone number is required", duration: const Duration(seconds: 2));
          return;
        }
      }

      final requestBody = {
        "fcmToken": fcmToken,
        "idToken": idToken,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
      };

      ApiResponse res = await _repo.googleSignIn(requestBody);

      if (res.statusCode == 200) {
        _handleSuccessfulLogin(res.data);
      } else {
        _log.e("Google Sign-In Error: ${res.data}");
        _snackBar.showSnackbar(message: res.data["message"], duration: const Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Google Sign-In Error: $e");
      _snackBar.showSnackbar(message: "An error occurred during Google Sign-In", duration: const Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }


  // --- Helper Methods ---

  void _handleVerificationFlow(dynamic data) {
    profile.value.id = data['userId'];
    profile.value.reference = data['sendTokenResponse']?['data']?['token'] ?? '';
    _navigationService.navigateTo(
      Routes.authView,
      arguments: AuthViewArguments(
        initialPage: PresentPage.signup,
        parametersArg: {
          'isOtpRequested': 'true',
          'userId': data['userId'],
          if (phone.text.isNotEmpty) 'verificationCode': data['sendTokenResponse']?['data']?['token'],
          if (phone.text.isNotEmpty) 'phone': phone.text,
          if (email.text.isNotEmpty) 'email': email.text,
        },
      ),
    );
  }

  void _handleIncompleteProfileFlow(dynamic data) {
    profile.value.id = data['userId'];
    _navigationService.navigateTo(
      Routes.authView,
      arguments: AuthViewArguments(
        initialPage: PresentPage.register,
        parametersArg: {
          'userId': data['userId'],
          if (phone.text.isNotEmpty) 'phone': phone.text,
          if (email.text.isNotEmpty) 'email': email.text,
        },
      ),
    );
  }

  void _handleSuccessfulLogin(dynamic data) {
    userLoggedIn.value = true;
    profile.value = Profile.fromJson(Map<String, dynamic>.from(data["User"]));
    _localStorage.save(LocalStorageDir.authToken, data["token"]);
    _localStorage.save(LocalStorageDir.authRefreshToken, data["refreshToken"]);
    _localStorage.save(LocalStorageDir.authUser, jsonEncode(data["User"]));

    _navigationService.clearStackAndShow(Routes.homeView);
  }
}