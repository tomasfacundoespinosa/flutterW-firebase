import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa firebase_auth
import 'stock_management.dart';
import 'registro.dart'; // Importa la página de registro

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                try {
                  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // Si el inicio de sesión es exitoso, navegar a la página de gestión de stock
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Gestión de Stock')),
                  );
                  // Handle successful login
                  print('User logged in: ${userCredential.user!.uid}');
                } catch (e) {
                  // Handle login errors
                  setState(() {
                    _errorMessage = 'Contraseña incorrecta';
                  });
                  print('Error logging in: $e');
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16.0), // Espacio entre el botón de login y el botón de registro
            ElevatedButton(
              onPressed: () {
                // Navegar a la página de registro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroPage()),
                );
              },
              child: Text('Registro'), // Texto del botón
            ),
            SizedBox(height: 10.0),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
