import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/user_auth_controller.dart';
import 'package:store_app/views/screens/auth_view/register_form.dart';

class LoginForm extends StatefulWidget { // widget que cambia en el tiempo 
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();// Clave global para el formulario, se usa para validar el formulario, es final porque no se va a cambiar en tiempo de ejecución, es decir, no se va a modificar el valor de la variable
  final _auth = UserAuthController(); 
  bool _PasswordVisible = false;


  late String email='';    // Variables que guardan los valores del formulario
  late String password='';

  bool procesing = false; // Controla el estado de carga

  // Función que maneja el inicio de sesión
  Future<void> loginUser() async {
    final isValid = _formKey.currentState!.validate(); // Verifica si el formulario es válido

    if (!isValid) return; // Si el formulario no es válido, termina todo

    _formKey.currentState!.save();
    setState(() => procesing = true); //indica que se inicia sesión

    try {
      await _auth.loginUsers(
        context: context,
        email: email,
        password: password,
      );

      _formKey.currentState!.reset(); // Limpia el formulario después de iniciar sesión

      setState(() {
        email = '';
        password = '';
      });

    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => procesing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold es un widget que proporciona una estructura básica para la pantalla, como la barra de navegación y el cuerpo
      backgroundColor: Colors.white.withOpacity(0.95), 
      body: Stack(
        children: [

          // DECORACIÓN DE LA OLA SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/svg/wave.svg', // Ola SVG decorativa
              width: MediaQuery.of(context).size.width,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          // CONTENIDO DEL FORMULARIO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey, // Asigna la clave global al formulario para poder validarlo
                child: Column(
                  children: [  //es una lista de widgets que se mostraran en la columna

                    //  WIDGET DE TEXTO --------------------------------------------------------------
                    Text(
                      "Inicio de sesión",
                      style: GoogleFonts.lato(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    //  WIDGET DE TEXTO --------------------------------------------------------------
                    Text(
                      "Cuida tus plantas con nosotros",
                      style: GoogleFonts.lato(fontSize: 14),
                    ),

                    //WIDGET DE IMAGEN --------------------------------------------------------------, muestra la imagen desde la carpeta assets/images, se le puede dar un ancho y alto
                    Image.asset( 
                      'assets/images/pexels-kelly-1179532-2559933-Photoroom.png',
                      width: 200,
                      height: 200,
                    ),

                    const SizedBox(height: 25),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correo electrónico',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          onSaved: (value) => email = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su correo';
                            }
                            return null; // Si el campo de texto no esta vacio, devuelve null para indicar que no hay errores de validación
                          },
                          decoration: InputDecoration(
                            hintText: 'Ejemplo: usuario@gmail.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),



                    const SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contraseña',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: !_PasswordVisible,
                          onSaved: (value) => password = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su contraseña';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Mínimo 8 caracteres',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _PasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _PasswordVisible = !_PasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 30),

                    // BOTÓN INICIAR SESIÓN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: procesing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login, color: Colors.white),

                        label: Text(
                          procesing ? 'Iniciando...' : 'Iniciar sesión',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: procesing ? null : loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF317E30), // Verde institucional
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // WIDGET de fila, hace que todos los elementos que se pongan dentro se muestren horizontalmente, uno al lado de otro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta?',
                          style: GoogleFonts.roboto(letterSpacing: 1),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegisterForm()),
                            ); // Navega a la pantalla de registro al tocar el texto, materialPageRoute es una clase que crea una ruta para navegar a otra pantall
                          },
                          child: Text(
                            'Regístrate',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFF5fa65e),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
