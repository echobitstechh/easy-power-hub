import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Perform Firebase authentication to get a valid ID token
      final firebase_auth.AuthCredential credential =
      firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Get the Firebase ID token
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      // Get user details with improved null safety
      final String? email = userCredential.user?.email;
      final String? displayName = userCredential.user?.displayName;

      // Safely extract first and last name
      String firstName = '';
      String lastName = '';

      if (displayName != null) {
        final nameParts = displayName.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.last : '';
      }

      print("Google Sign-In Email: $email");
      print("Firebase ID Token: $firebaseIdToken");

      // Return Google user details
      return {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'idToken': firebaseIdToken,
      };

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