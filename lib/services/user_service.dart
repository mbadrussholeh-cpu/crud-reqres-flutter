import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ApiException implements Exception {
final String message;
ApiException(this.message);

@override
String toString() => message;
}

class UserService {
static const String _baseUrl = 'https://reqres.in/api';
static const String _apiKey = 'reqres-free-v1';

static const Map<String, String> _headers = {
'Content-Type': 'application/json',
'x-api-key': _apiKey,
};

Future<http.Response> _send(Future<http.Response> Function() request) async {
try {
final response = await request().timeout(const Duration(seconds: 15));
if (response.statusCode < 200 || response.statusCode > 299) {
throw ApiException(
'Server mengembalikan error (status ${response.statusCode}).');
}
return response;
} on ApiException {
rethrow;
} on SocketException {
throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
} on http.ClientException {
throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
} on TimeoutException {
throw ApiException('Koneksi timeout. Silakan coba lagi.');
} on FormatException {
throw ApiException('Format data dari server tidak valid.');
} catch (e) {
throw ApiException('Terjadi kesalahan: $e');
}
}

Future<List<UserModel>> getUsers({int page = 1}) async {
final response = await _send(
() => http.get(Uri.parse('$_baseUrl/users?page=$page'), headers: _headers),
);
final body = jsonDecode(response.body) as Map<String, dynamic>;
final List data = body['data'] ?? [];
return data
    .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
    .toList();
}

Future<UserModel> createUser(UserModel user) async {
final response = await _send(
() => http.post(
Uri.parse('$_baseUrl/users'),
headers: _headers,
body: jsonEncode(user.toJson()),
),
);
final body = jsonDecode(response.body) as Map<String, dynamic>;
return user.copyWith(id: int.tryParse('${body['id']}'));
}

Future<UserModel> updateUser(UserModel user) async {
if (user.id == null) throw ApiException('ID user tidak ditemukan.');
await _send(
() => http.put(
Uri.parse('$_baseUrl/users/${user.id}'),
headers: _headers,
body: jsonEncode(user.toJson()),
),
);
return user;
}

Future<void> deleteUser(int id) async {
await _send(
() => http.delete(Uri.parse('$_baseUrl/users/$id'), headers: _headers),
);
}
}
