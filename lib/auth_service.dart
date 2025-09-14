import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
          clientId: '8842383345-sjauiebtr0i3hkmjt2kgb12159fa2ta6.apps.googleusercontent.com',
        )
      : GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
          serverClientId: '8842383345-gv0dcjq6stth6vgn8msq01p3r97vkorg.apps.googleusercontent.com',
        );

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(fullName);
      await result.user?.reload();

      // Save login state
      await _saveLoginState(true);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login state
      await _saveLoginState(true);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from previous Google account first
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('accessToken: ${googleAuth.accessToken}');
      print('idToken: ${googleAuth.idToken}');

      // Check if we got the tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      // Save login state
      await _saveLoginState(true);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear login state
      await _saveLoginState(false);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    }
  }

  // Save login state to SharedPreferences
  static Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', isLoggedIn);
  }

  // Get user-friendly error messages
  static String _getAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'user-cancelled':
        return 'Sign in was cancelled.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}