import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/utils/model_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  List<double>? _predictions;
  bool _isLoading = false;
  bool _modelLoaded = false;

  final List<String> classLabels = [
    'Bacterial',
    'Fungal',
    'Healthy',
    'Leaf Spots',
    'Viral',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await ModelHelper.initModel();
      setState(() => _modelLoaded = true);
    } catch (e) {
      _showMessage('Error al cargar el modelo: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _predictions = null;
      _isLoading = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final predictions = ModelHelper.classifyImage(Uint8List.fromList(bytes));

      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error al procesar imagen: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: _image != null
              ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
              : null,
          color: _image == null ? Colors.grey[100] : null,
        ),
        child: _image == null
            ? Center(
                child: Icon(Icons.image_outlined, size: 80, color: Colors.grey))
            : null,
      ),
    );
  }

  Widget _buildResult() {
    if (_predictions == null) return SizedBox();

    final maxProb = _predictions!.reduce((a, b) => a > b ? a : b);
    final predictedIndex = _predictions!.indexOf(maxProb);
    final predictedLabel = classLabels[predictedIndex];
    final confidence = (maxProb * 100).toStringAsFixed(2);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '$predictedLabel',
              style: TextStyle(fontSize: 22, color: Colors.green[800]),
            ),
            Text(
              'Confianza: $confidence%',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: maxProb,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text('Cámara'),
            onPressed: _modelLoaded ? () => _pickImage(ImageSource.camera) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Galería'),
            onPressed: _modelLoaded ? () => _pickImage(ImageSource.gallery) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo claro
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Clasificador de Hojas de Tomate'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                if (!_modelLoaded)
                  CircularProgressIndicator()
                else ...[
                  _buildImagePreview(),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else
                    _buildResult(),
                  _buildButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
