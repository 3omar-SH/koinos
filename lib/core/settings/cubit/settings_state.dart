import 'package:flutter/material.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState {
  final ThemeMode themeMode;
  final String userName;
  final String email;
  final String photoUrl;
  final SettingsStatus status;
  final String message;
  final bool isDeleting;
  final bool isSignedOut;

  SettingsState({
    required this.themeMode,
    required this.userName,
    this.email = '',
    this.photoUrl = '',
    this.status = SettingsStatus.initial,
    this.message = '',
    this.isDeleting = false,
    this.isSignedOut = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? userName,
    String? email,
    String? photoUrl,
    SettingsStatus? status,
    String? message,
    bool? isDeleting,
    bool? isSignedOut,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? SettingsStatus.initial,
      message: message ?? this.message,
      isDeleting: isDeleting ?? this.isDeleting,
      isSignedOut: isSignedOut ?? this.isSignedOut,
    );
  }
}
