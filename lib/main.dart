import 'package:flutter/material.dart';
import 'package:store_app/views/screens/auth_view/login_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Elimina el banner de depuración en la esquina superior derecha
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 183, 81)),
      ),
      home: LoginForm(),  // pantalla home de la aplicacion, donde se muestra el login
    );
  }
}

