import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Box settingsBox;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SettingsCubit(this.settingsBox)
      : super(SettingsState(
          themeMode: settingsBox.get('isDarkMode', defaultValue: false)
              ? ThemeMode.dark
              : ThemeMode.light,
          userName: FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email?.split('@').first ??
              "User",
          email: FirebaseAuth.instance.currentUser?.email ?? '',
          photoUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: SettingsStatus.initial, isSignedOut: true));
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final storedUsername = doc.data()?['username'] as String?;

      emit(state.copyWith(
        userName: storedUsername != null && storedUsername.isNotEmpty
            ? storedUsername
            : state.userName,
        status: SettingsStatus.initial,
      ));
    } catch (_) {}
  }

  void toggleTheme() {
    final isDark = state.themeMode == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;

    settingsBox.put('isDarkMode', !isDark);

    emit(state.copyWith(themeMode: newMode, status: SettingsStatus.initial));
  }

  Future<void> updateUserName(String newName) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'username': newName});

        emit(state.copyWith(
          userName: newName,
          status: SettingsStatus.success,
          message: "Name updated successfully!",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        message: "Failed to update name: ${e.toString()}",
      ));
    }
  }

  Future<void> uploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile == null) return;

      emit(state.copyWith(status: SettingsStatus.loading));

      User? user = _auth.currentUser;

      if (user != null) {
        const String cloudName = "do56ktjev";
        const String uploadPreset = "koinos";

        final dio = Dio();

        final formData = FormData.fromMap({
          "upload_preset": uploadPreset,
          "file": await MultipartFile.fromFile(pickedFile.path),
        });

        final response = await dio.post(
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
          data: formData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final String downloadUrl = response.data['secure_url'];

          await user.updatePhotoURL(downloadUrl);
          await user.reload();

          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'photoUrl': downloadUrl});

          emit(state.copyWith(
            photoUrl: downloadUrl,
            status: SettingsStatus.success,
            message: "Profile image updated successfully!",
          ));
        } else {
          throw Exception("Failed to upload image to Cloudinary");
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        message: "Failed to upload image: ${e.toString()}",
      ));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(state.copyWith(status: SettingsStatus.initial, isSignedOut: true));
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: SettingsStatus.initial, isSignedOut: true));
      return;
    }

    emit(state.copyWith(status: SettingsStatus.loading, isDeleting: true));

    try {
      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (_) {}

      await user.delete();

      emit(state.copyWith(
        status: SettingsStatus.initial,
        isDeleting: false,
        isSignedOut: true,
      ));
    } on FirebaseAuthException catch (e) {
      final failureMessage = e.code == 'requires-recent-login'
          ? 'For your security, please sign out, sign back in, then try deleting your account again.'
          : 'Failed to delete account: ${e.message ?? e.code}';

      emit(state.copyWith(
        status: SettingsStatus.failure,
        isDeleting: false,
        message: failureMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        isDeleting: false,
        message: "Failed to delete account: ${e.toString()}",
      ));
    }
  }
}
