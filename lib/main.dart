import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:mi_tienda_app/screens/home_screen.dart'; // Asegúrate que la ruta sea correcta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos nuestra paleta de colores
    const primaryColor = Color(0xFF3A7CFF); // Un azul vibrante
    const backgroundColor = Color(0xFF1E202C); // Un fondo oscuro desaturado
    const cardColor = Color(0xFF252836); // Un color ligeramente más claro para las tarjetas

    return MaterialApp(
      title: 'Inventario Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: primaryColor,
          background: backgroundColor,
          surface: cardColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          floatingLabelStyle: const TextStyle(color: primaryColor),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
        )
      ),
      // <<< OJO: Cambiamos la pantalla de inicio a un 'AuthWrapper' para manejar el login >>>
      // Esto es una mejora: decide si mostrar Login o Home basado en el estado de autenticación
      home: AuthWrapper(), 
    );
  }
}

// <<< WIDGET NUEVO Y MEJORADO para manejar el estado de autenticación >>>
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Este widget escuchará los cambios de autenticación
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras espera, muestra un cargador
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Si tiene datos (el usuario está logueado), muestra HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Si no, muestra la pantalla de Login
        return const LoginPage();
      },
    );
  }
}


// <<< LoginPage (solo la clase, el resto del archivo main.dart debe tener esto) >>>
// Puedes mantener tu LoginPage como estaba, pero aquí te dejo una versión
// que se adaptará mejor al nuevo tema.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signIn() async {
    // ... (la lógica de signIn no cambia)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Inventario Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: signIn,
                child: const Text('Iniciar Sesión'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// <<< NO OLVIDES >>>
// Necesitarás importar FirebaseAuth para el AuthWrapper y LoginPage.
// import 'package:firebase_auth/firebase_auth.dart';