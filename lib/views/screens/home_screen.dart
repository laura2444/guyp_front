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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Clasificador de Plantas',
        showBackButton: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
              if (value == 'debug') _debugSession();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report_rounded, size: 20, color: Colors.grey[700]),
                    SizedBox(width: 12),
                    Text('Depurar sesión'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildModelSelection(),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_rounded,
                  size: 80,
                  color: Colors.orange[400],
                ),
              ),
              SizedBox(height: 32),

              // Título
              Text(
                'No hay usuario autenticado',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Descripción
              Text(
                'Necesitas iniciar sesión para usar la aplicación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32),

              // Botón principal
              ElevatedButton.icon(
                icon: Icon(Icons.login_rounded, size: 20),
                label: Text('Iniciar sesión'),
                onPressed: _goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),

              SizedBox(height: 16),

              // Botón depurar
              TextButton.icon(
                icon: Icon(Icons.bug_report_rounded, size: 18),
                label: Text('Depurar almacenamiento'),
                onPressed: _debugStorage,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),

              SizedBox(height: 32),
              Divider(),
              SizedBox(height: 32),

              // Sección de prueba
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science_rounded, color: Colors.blue[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Modo de prueba',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createTestUser,
                      icon: Icon(Icons.person_add_rounded, size: 18),
                      label: Text('Crear usuario de prueba'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.bug_report_rounded, color: Colors.orange[700]),
            SizedBox(width: 12),
            Text('Depuración de Sesión'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugItem('User ID', session['user_id'] ?? "NULL"),
              _buildDebugItem('Longitud', '${session['user_id']?.length ?? 0}'),
              _buildDebugItem('Email', session['email'] ?? "NULL"),
              _buildDebugItem('Nombre', session['name'] ?? "NULL"),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await storage.clearUserSession();
                  Navigator.pop(context);
                  _loadUserId();
                },
                icon: Icon(Icons.delete_sweep_rounded, size: 18),
                label: Text('Borrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.storage_rounded, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Almacenamiento'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugItem('User ID', session['user_id'] ?? "NULL"),
              _buildDebugItem('Email', session['email'] ?? "NULL"),
              _buildDebugItem('Nombre', session['name'] ?? "NULL"),
              _buildDebugItem('Token', session['token'] != null ? "Presente" : "NULL"),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await storage.clearAll();
                  Navigator.pop(context);
                  _loadUserId();
                },
                icon: Icon(Icons.delete_forever_rounded, size: 18),
                label: Text('Borrar TODO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
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

  Widget _buildDebugItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createTestUser() async {
    final mockObjectId = _generateMockObjectId();

    final storage = SecureStorageService();
    await storage.saveUserSession({
      'id': mockObjectId,
      'email': 'test@ejemplo.com',
      'name': 'Usuario de Prueba',
      'token': 'mock_token_123',
    });

    print('👤 Usuario de prueba creado: $mockObjectId');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Usuario de prueba creado'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    _loadUserId();
  }

  String _generateMockObjectId() {
    final chars = '0123456789abcdef';
    final random = Random();
    return List.generate(24, (i) => chars[random.nextInt(chars.length)]).join();
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el cultivo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Elige el tipo de planta que deseas analizar',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Lista de modelos
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            physics: BouncingScrollPhysics(),
            children: [
              ModelSelectionCard(
                title: 'Tomate',
                type: PlantModel.tomato,
                icon: Icons.spa_rounded,
                color: Colors.red,
                onTap: () => _navigateToClassifier(PlantModel.tomato),
              ),

              ModelSelectionCard(
                title: 'Pimiento',
                type: PlantModel.pepper,
                icon: Icons.local_florist_rounded,
                color: Colors.green,
                onTap: () => _navigateToClassifier(PlantModel.pepper),
              ),

              ModelSelectionCard(
                title: 'Papa',
                type: PlantModel.potato,
                icon: Icons.grass_rounded,
                color: Colors.orange,
                onTap: () => _navigateToClassifier(PlantModel.potato),
              ),

              SizedBox(height: 8),

              // Tarjeta informativa
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Toma una foto clara de las hojas para obtener mejores resultados',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToClassifier(PlantModel model) {
    print('👉 userId actual: $_userId');

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('No hay usuario autenticado'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassifierScreen(
          selectedModel: model,
          userId: _userId!,
        ),
      ),
    );
  }
}