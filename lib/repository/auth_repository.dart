// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:docsgoogle/constants/colors.dart';
import 'package:docsgoogle/models/error_model.dart';
import 'package:docsgoogle/models/user_module.dart';
import 'package:docsgoogle/repository/local_storage_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    localStorageRepository: LocalStorageRepository(),
    client: Client(),
    googleSignIn: GoogleSignIn(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository localStorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> singInWithGoogle() async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userM = UserModel(
            email: user.email,
            name: user.displayName ?? "Unknow",
            profilePic: user.photoUrl ?? pictureDefault,
            uid: "",
            token: "");

        final response = await _client.post(Uri.parse("$urlApi/auth/signup"),
            headers: {"Content-Type": "application/json; charset=UTF-8"},
            body: userM.toJson());
        final data = jsonDecode(response.body) as Map;
        switch (response.statusCode) {
          case 200:
            final user = userM.copyWith(
              token: data["token"],
              uid: data["user"]["_id"],
            );
            erro = ErrorModel(error: null, data: user);
            _localStorageRepository.setToken(user.token);
            break;
          default:
            break;
        }
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      String? token = await _localStorageRepository.getToken();
      if (token != null) {
        final response = await _client.get(
          Uri.parse("$urlApi/auth"),
          headers: {
            "x-auth-token": token,
          },
        );
        final data = jsonDecode(response.body) as Map;
        switch (response.statusCode) {
          case 200:
            final user = UserModel.fromMap(data["user"]).copyWith(token: token);
            erro = ErrorModel(error: null, data: user);
            _localStorageRepository.setToken(user.token);
            break;
          default:
            break;
        }
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _localStorageRepository.setToken("");
  }
}
