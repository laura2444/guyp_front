import 'dart:math';
import 'package:flutter/material.dart';
import 'package:store_app/utils/plant_model.dart';
import 'package:store_app/widgets/custom_app_bar.dart';
import 'package:store_app/widgets/home/model_selection_card.dart';
import 'package:store_app/services/secure_storage_service.dart';
import 'package:store_app/views/screens/classifier_screen.dart';
import 'package:store_app/views/screens/auth_view/login_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final storage = SecureStorageService();
      final session = await storage.getUserSession();
      _userId = session['user_id'];

      print('✅ UserID desde SecureStorage: $_userId');

    } catch (e) {
      print('Error: $e');
    }

    setState(() => _loadingUser = false);
  }

  bool _isValidObjectId(String id) {
    if (id.length != 24) return false;
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return _buildLoadingScreen();
    }

    if (_userId == null || _userId!.isEmpty) {
      return _buildNoUserScreen();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Clasificador de Plantas',
        showBackButton: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
              if (value == 'debug') _debugSession();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, size: 20),
                    SizedBox(width: 8),
                    Text('Depurar sesión'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: _buildModelSelection(),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Cargando...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'No hay usuario autenticado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Necesitas iniciar sesión para usar la aplicación',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Ir a Login'),
                onPressed: _goToLogin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: _debugStorage,
                child: Text('Depurar almacenamiento'),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),
              Text(
                'Modo de prueba:',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _createTestUser,
                child: Text('Crear usuario de prueba'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginForm()),
          (route) => false,
    );
  }

  void _logout() async {
    final storage = SecureStorageService();
    await storage.clearUserSession();
    setState(() {
      _userId = null;
      _loadingUser = true;
    });
    _loadUserId();
  }

  void _debugSession() async {
    final storage = SecureStorageService();
    final session = await storage.getUserSession();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Depuración de Sesión'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('user_id: ${session['user_id'] ?? "NULL"}'),
              Text('Longitud: ${session['user_id']?.length ?? 0}'),
              Text('email: ${session['email']}'),
              Text('name: ${session['name']}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await storage.clearUserSession();
                  Navigator.pop(context);
                  _loadUserId();
                },
                child: Text('Borrar sesión'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _debugStorage() async {
    final storage = SecureStorageService();
    final session = await storage.getUserSession();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Depuración de Almacenamiento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('user_id: ${session['user_id'] ?? "NULL"}'),
              Text('email: ${session['email'] ?? "NULL"}'),
              Text('name: ${session['name'] ?? "NULL"}'),
              Text('token: ${session['token'] != null ? "Presente" : "NULL"}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await storage.clearAll();
                  Navigator.pop(context);
                  _loadUserId();
                },
                child: Text('Borrar TODO'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _createTestUser() async {
    // Crear un ObjectId válido para pruebas
    final mockObjectId = _generateMockObjectId();

    final storage = SecureStorageService();
    await storage.saveUserSession({
      'id': mockObjectId,
      'email': 'test@ejemplo.com',
      'name': 'Usuario de Prueba',
      'token': 'mock_token_123',
    });

    print('👤 Usuario de prueba creado: $mockObjectId');
    _loadUserId();
  }

  String _generateMockObjectId() {
    // Generar 24 caracteres hexadecimales
    final chars = '0123456789abcdef';
    final random = Random();
    return List.generate(24, (i) => chars[random.nextInt(chars.length)]).join();
  }

  Widget _buildModelSelection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona el cultivo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Elige el tipo de planta que deseas analizar',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),

          ModelSelectionCard(
            title: 'Tomate',
            type: PlantModel.tomato,
            icon: Icons.spa,
            color: Colors.red,
            onTap: () => _navigateToClassifier(PlantModel.tomato),
          ),
          SizedBox(height: 16),

          ModelSelectionCard(
            title: 'Pimiento',
            type: PlantModel.pepper,
            icon: Icons.local_florist,
            color: Colors.green,
            onTap: () => _navigateToClassifier(PlantModel.pepper),
          ),
          SizedBox(height: 16),

          ModelSelectionCard(
            title: 'Papa',
            type: PlantModel.potato,
            icon: Icons.grass,
            color: Colors.orange,
            onTap: () => _navigateToClassifier(PlantModel.potato),
          ),
        ],
      ),
    );
  }

  void _navigateToClassifier(PlantModel model) {
    print('👉 userId actual: $_userId');

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: No hay usuario autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassifierScreen(
          selectedModel: model,
          userId: _userId!, // ← AQUÍ FALTA ESTE PARÁMETRO
        ),
      ),
    );
  }
}