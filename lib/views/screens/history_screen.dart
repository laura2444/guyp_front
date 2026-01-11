import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/models/plant_analysis_model.dart';
import 'package:store_app/services/plant_analysis_service.dart';
import 'package:store_app/widgets/analysis_card.dart';
import 'package:store_app/services/secure_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<PlantAnalysisModel>> _futureAnalyses;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _futureAnalyses = _loadAnalyses();
  }

  Future<List<PlantAnalysisModel>> _loadAnalyses() async {
    final session = await SecureStorageService().getUserSession();
    final userId = session['user_id'];

    if (userId == null) {
      debugPrint('No hay sesión activa');
      return [];
    }

    try {
      final result = await getUserAnalyses(userId);
      return result;
    } catch (e) {
      debugPrint('Error al cargar análisis: $e');
      return [];
    }
  }

  Widget _buildAnimatedItem(PlantAnalysisModel analysis, Animation<double> animation) {
    final offsetTween = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(offsetTween),
        child: AnalysisCard(analysis: analysis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: Text(
          'Historial',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<PlantAnalysisModel>>(
        future: _futureAnalyses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el historial.',
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return Center(
              child: Text(
                'No hay análisis aún.',
                style: GoogleFonts.poppins(fontSize: 16, color: textColor),
              ),
            );
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: data.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index, animation) {
              return _buildAnimatedItem(data[index], animation);
            },
          );
        },
      ),
    );
  }
}
