// lib/providers/auth_provider.dart (verify this is unchanged)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  return AuthNotifier(ref.read(firebaseAuthProvider));
});

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth;

  AuthNotifier(this._auth) : super(const AsyncValue.data(null)) {
    _auth.setPersistence(Persistence.NONE); // Disable auto-login for testing
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        state = AsyncValue.data(user); // Update state on successful login
      } else {
        state = const AsyncValue.data(null); // Update state on logout
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(
        userCredential.user,
      ); // Update with authenticated user
    } finally {
      if (state is AsyncLoading) {
        state = const AsyncValue.data(
          null,
        ); // Reset to null if still loading (error case)
      }
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(
        userCredential.user,
      ); // Update with registered user
    } finally {
      if (state is AsyncLoading) {
        state = const AsyncValue.data(
          null,
        ); // Reset to null if still loading (error case)
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null); // Clear state on logout
  }
}
