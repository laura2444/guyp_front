import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 

void responseHttp({ 

  required http.Response response,  // Respuesta http del request que se hizo 
  required BuildContext ubication,  // Es la ubicación actual de un widget en la app, sirve para mostrar dialogos etc 
  required VoidCallback success, // Callback que se ejecuta cuando la respuesta es exitosa, voidcallback es un tipo de funcionq ue no recibe parametros ni retorna nada, solo se sabe que se ejecutará si todo va bien 

}){ 

  // Manejo de la respuesta http con los diferentes estados que pueda arrojar  
  final code = response.statusCode; 
  final body = json.decode(response.body); 

    // DEBUG: Imprime información completa
  print('=== DEBUG INFO ===');
  print('Status Code: $code');
  print('Response Body: ${response.body}');
  print('==================');
  

  if (code ==200 || code == 201) { // Si el código de estado es 200 o 201, se ejecuta el callback onSuccess 
    success(); 
  } else if (code == 400 || code == 500) { // Si el código de estado es 400 o 500, se muestra un mensaje de error 
    statusMessage(ubication, body['detail']['message'] ?? 'Error desconocido'); 
  }else if (code == 422) {
  final errors = body['detail'];
  if (errors is List && errors.isNotEmpty) {
    final msg = errors[0]['msg'] ?? 'Error de validación';
    statusMessage(ubication, msg);
  }
  }
  else { 
    statusMessage(ubication, 'Ha ocurrido un error inesperado'); 
  } 
} 
// Muestra un mensaje temporal en la parte inferior de la pantalla (llamado snack bar). Es útil para decirle al usuario cosas como: “Usuario registrado con éxito” 

void statusMessage(BuildContext ubication, String msg) {   //toma la ubicacion actual del widget para saber en donde mostrar el mensaje, title es el texto del mensaje que se quiere mostrar como "contraseña incorrecta" 
  ScaffoldMessenger.of(ubication).showSnackBar(   //scaffoldmessenger es un ayudante de flutter que puede mostrar mensajes temporales en la pantalla 
    SnackBar( 
      content: Text(msg),  //Aquí se crea el snack bar. Este snack bar es una cajita que tiene dentro un texto (Text(msg)) 
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ), 
  ); 
} 

 