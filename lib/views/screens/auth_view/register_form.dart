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

class _RegisterFormState extends State<RegisterForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _auth = UserAuthController();
  late String email = '';
  late String name = '';
  late String password = '';

  bool procesing = false;
  bool _PasswordVisible = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final isValid = _formKey.currentState!.validate();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? Colors.grey[850] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
/*          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/svg/wave.svg',
              width: MediaQuery.of(context).size.width,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),*/
          Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF388E3C).withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'GUYP',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF388E3C),
                              letterSpacing: 6,
                            ),
                          ),
                        ],
                      ), 
                      const SizedBox(height: 8),
                      Text(
                        "Registrate y empieza a cuidar tus plantas",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),         
                      const SizedBox(height: 30),
                      Text(
                        "Crear cuenta",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      /*
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/pexels-kelly-1179532-2559933-Photoroom.png',
                        height: 180,
                      ),*/
                      const SizedBox(height: 32),
                      Text(
                        'Correo electrónico',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onSaved: (value) => email = value ?? '',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor ingrese su correo'
                            : null,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Ejemplo: usuario@gmail.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nombre completo',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onSaved: (value) => name = value ?? '',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor ingrese su nombre completo'
                            : null,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Ejemplo: Juan Pérez',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Contraseña',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: !_PasswordVisible,
                        onSaved: (value) => password = value ?? '',
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor ingrese su contraseña'
                            : null,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Mínimo 8 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _PasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _PasswordVisible = !_PasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
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
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: procesing ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta?',
                            style: GoogleFonts.poppins(
                              letterSpacing: 0.5,
                              color: textColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginForm()),
                              );
                            },
                            child: Text(
                              'Inicia sesión',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
