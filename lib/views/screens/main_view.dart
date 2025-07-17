import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _pageIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Plantas', style: TextStyle(fontSize: 24))),
    Center(child: Text('Historial', style: TextStyle(fontSize: 24))),
    Center(child: Text('Cuenta', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_pageIndex], // ✅ AQUÍ SE AGREGA EL CONTENIDO DINÁMICO
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 50, 176, 39),
        unselectedItemColor: Colors.grey,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: "Plantas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Cuenta",
          ),
        ],
      ),
    );
  }
}
