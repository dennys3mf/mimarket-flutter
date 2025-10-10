import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_tienda_app/presentation/providers/auth_provider.dart';
import 'package:mi_tienda_app/presentation/screens/pos_screen.dart';
import 'package:mi_tienda_app/presentation/screens/admin_report_screen.dart';

/// Pantalla principal con navegación
/// Adapta la interfaz según el rol del usuario
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    // Pantallas disponibles
    final List<Widget> screens = [
      const POSScreen(),
      if (isAdmin) const AdminReportScreen(),
    ];

    // Items de navegación
    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.point_of_sale),
        label: 'Ventas',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Reportes',
        ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: navItems.length > 1
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: navItems,
            )
          : null,
    );
  }
}

