import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/user_auth_controller.dart';
import 'package:store_app/views/screens/auth_view/login_form.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
    // instancia de clase auth  para TENER ACCESO A LAS FUNCIONES DE LA CLASE, para recibir los parametros dijitados por el usuari para su posterior envio
  final _auth = UserAuthController();

  late String email= ''; //es late porque aún no conocemos su valor pero lo conoceremos más adelante
  late String name= '';
  late String password= '';

  bool procesing = false;
  bool _PasswordVisible = false;


  Future<void> registerUser() async {
    final isValid = _formKey.currentState!.validate(); // limpia formulario


    if (!isValid) return;

    _formKey.currentState!.save();

    setState(() => procesing = true);

    try {
      await _auth.registerUsers(
        context: context,
        email: email,
        name: name,
        password: password,
      );

      _formKey.currentState!.reset();

      setState(() {
        email = '';
        name = '';
        password = '';
      });

    } catch (e) {
      debugPrint('Error al registrarse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => procesing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Stack(
        children: [
          // Ola decorativa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/svg/wave.svg',
              width: MediaQuery.of(context).size.width,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //WIDGET DE TEXTO --------------------------------------------------------------
                    Text( 
                      "Crear cuenta",
                      style: GoogleFonts.lato(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    //WIDGET DE TEXTO --------------------------------------------------------------
                    Text(
                      "Regístrate y empieza a cuidar tus plantas",
                      style: GoogleFonts.lato(fontSize: 14),
                    ),

                    const SizedBox(height: 10),

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
                        // WIDGET DE CAMPO DE TEXTO --------------------------------------------------------------
                        TextFormField(
                          onSaved: (value) => email = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su correo';
                            }
                            
                            return null;
                          },
                          decoration: InputDecoration( // Decoracion del campo de texto, el input es porque es de entrada 
                            hintText: 'Ejemplo: usuario@gmail.com',
                            prefixIcon: const Icon(Icons.email_outlined),// prefixIcon sirve para mostrar un icono antes del texto del campo de texto
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
                            'Nombre completo',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            onSaved: (value) => name = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su nombre completo';
                              }
                              return null; // Si el campo de texto no esta vacio, devuelve null, lo que significa que no hay error de validacion
                            },
                            decoration: InputDecoration(
                              hintText: 'Ejemplo: Juan Pérez',
                              prefixIcon: const Icon(Icons.person_outline),
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
                            return null; // Si el campo de texto no esta vacio, devuelve null, lo que significa que no hay error de validacion
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


                    // Botón registrarse
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
                            : const Icon(Icons.person_add, color: Colors.white),

                        label: Text(
                          procesing ? 'Registrando...' : 'Registrarse',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: procesing ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF317E30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ir al login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta?',
                          style: GoogleFonts.roboto(letterSpacing: 1),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginForm()),
                            );
                          },
                          child: Text(
                            'Inicia sesión',
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
