import 'dart:convert';

import 'package:docsgoogle/constants/colors.dart';
import 'package:docsgoogle/models/document_model.dart';
import 'package:docsgoogle/models/error_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      final response = await _client.post(Uri.parse("$urlApi/document/create"),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            "x-auth-token": token,
          },
          body: jsonEncode({
            "createdAt": DateTime.now().millisecondsSinceEpoch,
          }));
      final data = jsonDecode(response.body) as Map;
      switch (response.statusCode) {
        case 200:
          erro = ErrorModel(
              error: null, data: DocumentModel.fromMap(data["document"]));
          break;
        default:
          erro = ErrorModel(error: data["error"], data: null);
          break;
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      final response = await _client.get(
        Uri.parse("$urlApi/document/me"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token,
        },
      );
      final data = jsonDecode(response.body) as Map;
      switch (response.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          List temp = data["documents"] as List;
          for (var t in temp) {
            documents.add(DocumentModel.fromMap(t));
          }
          erro = ErrorModel(error: null, data: documents);
          break;
        default:
          erro = ErrorModel(error: data["error"], data: null);
          break;
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }

  Future<ErrorModel> updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      final response = await _client.post(Uri.parse("$urlApi/document/title"),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            "x-auth-token": token,
          },
          body: jsonEncode({
            "title": title,
            "id": id,
          }));
      final data = jsonDecode(response.body) as Map;
      switch (response.statusCode) {
        case 200:
          erro = ErrorModel(
              error: null, data: DocumentModel.fromMap(data["document"]));
          break;
        default:
          erro = ErrorModel(error: data["error"], data: null);
          break;
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel erro =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      final response = await _client.get(
        Uri.parse("$urlApi/document/$id"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token,
        },
      );
      final data = jsonDecode(response.body) as Map;
      switch (response.statusCode) {
        case 200:
          erro = ErrorModel(
              error: null, data: DocumentModel.fromMap(data["document"]));
          break;
        default:
          throw "This document does no esit, please create";
      }
    } catch (e) {
      debugPrint("$e");
      erro = ErrorModel(error: e.toString(), data: null);
    }
    return erro;
  }
}
