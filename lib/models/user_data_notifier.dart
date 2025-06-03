import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataNotifier extends ChangeNotifier {
  String? _displayName;
  String? _photoURL;

  UserDataNotifier() {
    final user = FirebaseAuth.instance.currentUser;
    _displayName = user?.displayName;
    _photoURL = user?.photoURL;
  }

  String? get displayName => _displayName;
  String? get photoURL => _photoURL;

  Future<void> reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    _displayName = user?.displayName;
    _photoURL = user?.photoURL;
    notifyListeners();
  }
}
