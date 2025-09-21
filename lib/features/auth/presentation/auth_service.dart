import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // If the user cancels the sign-in, googleUser will be null.
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Ensure a valid ID token is received before proceeding.
      if (googleAuth.idToken == null) {
        throw Exception('Google ID Token is null.');
      }

      final firebase_auth.AuthCredential credential =
      firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Check if the user object is valid before continuing.
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase user is null after sign-in.');
      }

      final String? firebaseIdToken = await user.getIdToken();
      if (firebaseIdToken == null) {
        throw Exception('Firebase ID Token is null.');
      }

      // Safely extract and default user details
      final String email = user.email ?? '';
      final String displayName = user.displayName ?? '';
      final String phoneNumber = user.phoneNumber ?? '';

      String firstName = '';
      String lastName = '';

      if (displayName.isNotEmpty) {
        final nameParts = displayName.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      print("Google Sign-In Email: $email");
      print("Firebase ID Token: $firebaseIdToken");

      return {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'idToken': firebaseIdToken,
        'isNewUser': isNewUser,
      };

    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}