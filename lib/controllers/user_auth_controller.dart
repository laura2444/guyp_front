import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:store_app/global_variables.dart';
import 'package:store_app/models/userModel.dart';
import 'package:store_app/services/response_http.dart';
import 'package:store_app/views/screens/auth_view/login_form.dart';
import 'package:store_app/views/screens/main_view.dart';
import 'package:store_app/services/secure_storage_service.dart';

class UserAuthController {
  // Función asíncrona que se llama cuando el usuario presiona "Registrarse"
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<void> registerUsers({
    required BuildContext context,
    required String email,
    required String name,
    required String password,
  }) async {
    final newUser = UserModel(
      id: '',
      name: name,
      email: email,
      password: password,
      token: '',
    );

    try {
      final ur = Uri.parse('$uri/auth/signup');
      final response = await http.post(
        ur,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: newUser.toJsonString(),
      );

      responseHttp(
        response: response,
        ubication: context,
        success: () {
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginForm()),
            (route) => false,
          );
          statusMessage(context, 'Cuenta registrada con éxito');
        },
      );
    } catch (e) {
      debugPrint('Registro fallido: $e');
    }
  }

  Future<void> loginUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final loginData = jsonEncode({'email': email, 'password': password});

    try {
      final url = Uri.parse('$uri/auth/signin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: loginData,
      );

      responseHttp(
        response: response,
        ubication: context,
        success: () async {
          final data = jsonDecode(response.body);

          // ✅ Guardamos la sesión de forma segura
          await _secureStorage.saveUserSession(data);

          if (context.mounted) {
            statusMessage(context, 'Has iniciado sesión correctamente');

            await Future.delayed(const Duration(milliseconds: 300));

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainView()),
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error en login: $e');
      if (context.mounted) {
        statusMessage(context, 'Error al iniciar sesión: $e');
      }
    }
  }
}
