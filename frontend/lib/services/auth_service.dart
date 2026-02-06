import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use the singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Sign up
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(name);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Version 7.2.0: Use authenticate() instead of signIn()
      // authenticate() throws on error or cancellation
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        // accessToken is no longer explicitly required/available in Authentication object for v7
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      // GoogleSignIn.authenticate throws if cancelled (often silently or with specific code)
      // We can log it or just return null silently if it's a "cancellation"
      // Re-throwing universal string might obscure "User cancelled"
      if (e.toString().contains('canceled')) return null;
      throw 'An unknown error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Current user stream
  Stream<User?> get user => _auth.authStateChanges();
}
