import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'navigator.dart';
import 'theme_logic.dart'; 

void main() {
  runApp(
    
    ChangeNotifierProvider(
      create: (context) => ThemeLogic(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = context.watch<ThemeLogic>(); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Landmark Manager',

      
    theme: ThemeData(
      fontFamily: 'Saira',
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
      scaffoldBackgroundColor: const Color.fromARGB(255, 248, 211, 243), // Light background
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color.fromARGB(255, 59, 1, 47)),
        headlineMedium: TextStyle(
          color: Color.fromARGB(255, 59, 1, 47), 
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 240, 169, 235), // Light AppBar background
        foregroundColor: Color.fromARGB(255, 59, 1, 47),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:  Color.fromARGB(255, 240, 169, 235), 
        selectedItemColor: Color.fromARGB(255, 59, 1, 47), 
        unselectedItemColor: Color.fromARGB(255, 150, 74, 139), 
      ),
      cardColor: const Color.fromARGB(255, 255, 240, 247),
      iconTheme: IconThemeData(
            color: Color.fromARGB(255, 59, 1, 47),
      ),
    ),
    darkTheme: ThemeData(
      fontFamily: 'Saira',
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color.fromARGB(255, 17, 0, 14), // Dark background
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color.fromARGB(255, 240, 169, 235)),
        headlineMedium: TextStyle(
          color:Color.fromARGB(255, 240, 169, 235),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 59, 1, 47), // Dark AppBar background
        foregroundColor: Color.fromARGB(255, 240, 169, 235),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 59, 1, 47), // Example dark color (deep navy)
        selectedItemColor:  Color.fromARGB(255, 240, 169, 235), // Light pink for prominence
        unselectedItemColor: Color.fromARGB(255, 163, 70, 155), // Darker gray
      ),
      cardColor: const Color.fromARGB(255, 36, 0, 29),
      iconTheme: IconThemeData(
            color: Color.fromARGB(255, 240, 169, 235),
      ),
    ),
      
      themeMode: themeProvider.themeMode, 
      
      
      home: const MainNavigator(),
    );
  }
}