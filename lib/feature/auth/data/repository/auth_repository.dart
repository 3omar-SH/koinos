import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(username);
    await credential.user!.sendEmailVerification();

    await _firestore.collection('users').doc(credential.user!.uid).set(
      UserModel(
        uid: credential.user!.uid,
        username: username,
        email: email,
      ).toMap(),
    );

    await _auth.signOut();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    credential.user!.reload();

    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Please verify your email before signing in.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) throw Exception('cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final user = userCredential.user!;
    await _firestore.collection('users').doc(user.uid).set(
      UserModel(
        uid: user.uid,
        username: user.displayName ?? '',
        email: user.email ?? '',
      ).toMap(),
      SetOptions(merge: true),
    );
  }
}
