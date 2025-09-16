// lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/routes/app_routes.dart';
import '../local/session_storage.dart';
import "presentation/routes/app_routes.dart";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSession = await SessionStorage.hasSession();
  runApp(MyApp(initialRoute: hasSession ? AppRoutes.work : AppRoutes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovilEdiciones',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,                 // '/' si es login
      onGenerateRoute: AppRoutes.generateRoute,  // <-- usa tu switch
      // onUnknownRoute: (settings) => MaterialPageRoute(
      //   builder: (_) => const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
      // ),
      theme: ThemeData(useMaterial3: true),
    );
  }
}
