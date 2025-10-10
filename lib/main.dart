import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Core
import 'package:mi_tienda_app/core/theme/app_theme.dart';

// Services
import 'package:mi_tienda_app/data/services/firebase_auth_service.dart';
import 'package:mi_tienda_app/data/services/firestore_service.dart';
import 'package:mi_tienda_app/data/services/offline_sync_service.dart';

// Repositories
import 'package:mi_tienda_app/data/repositories/product_repository.dart';
import 'package:mi_tienda_app/data/repositories/sale_repository.dart';

// Providers
import 'package:mi_tienda_app/presentation/providers/auth_provider.dart';
import 'package:mi_tienda_app/presentation/providers/product_provider.dart';
import 'package:mi_tienda_app/presentation/providers/cart_provider.dart';
import 'package:mi_tienda_app/presentation/providers/sales_report_provider.dart';

// Screens
import 'package:mi_tienda_app/presentation/screens/login_screen.dart';
import 'package:mi_tienda_app/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilitar persistencia offline de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar servicios
    final authService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final offlineSyncService = OfflineSyncService(firestoreService);
    
    // Inicializar repositorios
    final productRepository = ProductRepository(firestoreService);
    final saleRepository = SaleRepository(firestoreService, offlineSyncService);

    // Iniciar sincronización automática
    offlineSyncService.startAutoSync();

    return MultiProvider(
      providers: [
        // Providers de autenticación
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        
        // Providers de productos
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        
        // Providers de carrito
        ChangeNotifierProvider(
          create: (_) => CartProvider(saleRepository),
        ),
        
        // Providers de reportes
        ChangeNotifierProvider(
          create: (_) => SalesReportProvider(saleRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Venta Rápida Minimarket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper de autenticación
/// Decide qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

